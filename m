From: Benjamin Poirier <benjamin.poirier@gmail.com>
Subject: Re: [PATCH net v5 0/5] bnx2x: fixes
Date: Tue, 13 Aug 2013 10:07:15 -0400
Message-ID: <20130813140715.GA4394@d2.synalogic.ca>
References: <1376349903-3461-1-git-send-email-dmitry@broadcom.com>
 <20130813123043.GA30192@d2.synalogic.ca>
 <6AE768456CEC4B4A9B2248CB6B87EB3E1BEB957E@SJEXCHMB05.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dmitry Kravkov <dmitry@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eilon Greenstein <eilong@broadcom.com>
To: Ariel Elior <ariele@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f176.google.com ([209.85.216.176]:57311 "EHLO
	mail-qc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757419Ab3HMOHT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 10:07:19 -0400
Received: by mail-qc0-f176.google.com with SMTP id u12so4109018qcx.35
        for <netdev@vger.kernel.org>; Tue, 13 Aug 2013 07:07:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <6AE768456CEC4B4A9B2248CB6B87EB3E1BEB957E@SJEXCHMB05.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/08/13 12:38, Ariel Elior wrote:
> > I'm confused. Wasn't "[PATCH net v4 1/6] bnx2x: properly initialize
> > statistic counters" supposed to fix a race condition? According to
> > earlier communication with Ariel:
> > 	In this issue a race condition at driver startup causes a second
> > 	statistics query to be sent before the first one completes,
> > 	resulting in a firmware assert and a stuck chip. A patch was
> > 	sent upstream fixing this:
> > 	http://patchwork.ozlabs.org/patch/264810/
> 
> As I explicitly mentioned in the communique which you quoted above, the patch was sent but not yet accepted.
> This is precisely the upstream process - patches are being sent, reviewed and sometimes rejected and revised.
> If you have further questions please address them to me - the technical forum is no place for this kind of discussion.
> Thanks,
> Ariel
> 

It's a technical question about a patch which was sent upstream. Where
should the discussion happen if not upstream?

Let me rephrase my question:

I'm confused. I thought that "[PATCH net v4 1/6] bnx2x: properly
initialize statistic counters" was meant to fix a race condition at
driver startup which causes a second statistics query to be sent before
the first one completes, resulting in a firmware assert and a stuck
chip. Am I mistaken and there is no such race condition, or is it
addressed by the other patches in this series?
