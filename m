From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: RE: [PATCH net v5 0/5] bnx2x: fixes
Date: Tue, 13 Aug 2013 14:16:37 +0000
Message-ID: <504C9EFCA2D0054393414C9CB605C37F20D708BF@SJEXCHMB06.corp.ad.broadcom.com>
References: <1376349903-3461-1-git-send-email-dmitry@broadcom.com>
 <20130813123043.GA30192@d2.synalogic.ca>
 <6AE768456CEC4B4A9B2248CB6B87EB3E1BEB957E@SJEXCHMB05.corp.ad.broadcom.com>
 <20130813140715.GA4394@d2.synalogic.ca>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Benjamin Poirier" <benjamin.poirier@gmail.com>,
	"Ariel Elior" <ariele@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1564 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756286Ab3HMOQq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 10:16:46 -0400
In-Reply-To: <20130813140715.GA4394@d2.synalogic.ca>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Benjamin Poirier
> Sent: Tuesday, August 13, 2013 5:07 PM
> To: Ariel Elior
> Cc: Dmitry Kravkov; davem@davemloft.net; netdev@vger.kernel.org; Eilon
> Greenstein
> Subject: Re: [PATCH net v5 0/5] bnx2x: fixes
> 
> On 2013/08/13 12:38, Ariel Elior wrote:
> > > I'm confused. Wasn't "[PATCH net v4 1/6] bnx2x: properly initialize
> > > statistic counters" supposed to fix a race condition? According to
> > > earlier communication with Ariel:
> > > 	In this issue a race condition at driver startup causes a second
> > > 	statistics query to be sent before the first one completes,
> > > 	resulting in a firmware assert and a stuck chip. A patch was
> > > 	sent upstream fixing this:
> > > 	http://patchwork.ozlabs.org/patch/264810/
> >
> > As I explicitly mentioned in the communique which you quoted above,
> the patch was sent but not yet accepted.
> > This is precisely the upstream process - patches are being sent, reviewed
> and sometimes rejected and revised.
> > If you have further questions please address them to me - the technical
> forum is no place for this kind of discussion.
> > Thanks,
> > Ariel
> >
> 
> It's a technical question about a patch which was sent upstream. Where
> should the discussion happen if not upstream?
> 
> Let me rephrase my question:
> 
> I'm confused. I thought that "[PATCH net v4 1/6] bnx2x: properly initialize
> statistic counters" was meant to fix a race condition at driver startup which
> causes a second statistics query to be sent before the first one completes,
> resulting in a firmware assert and a stuck chip. Am I mistaken and there is no
> such race condition, or is it addressed by the other patches in this series?
> 
There is such condition, but it's not caused by wrongly initialized counted -
the initialization done in a correct way. Patch "[PATCH net v5 1/5] bnx2x: protect
different statistics flows"  - prevents from two outstanding queries to be sent
simultaneously.

Thanks
Dmitry
