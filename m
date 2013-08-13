From: Benjamin Poirier <benjamin.poirier@gmail.com>
Subject: Re: [PATCH net v5 0/5] bnx2x: fixes
Date: Tue, 13 Aug 2013 13:44:17 -0400
Message-ID: <20130813174417.GA6822@d2.synalogic.ca>
References: <1376349903-3461-1-git-send-email-dmitry@broadcom.com>
 <20130813123043.GA30192@d2.synalogic.ca>
 <6AE768456CEC4B4A9B2248CB6B87EB3E1BEB957E@SJEXCHMB05.corp.ad.broadcom.com>
 <20130813140715.GA4394@d2.synalogic.ca>
 <504C9EFCA2D0054393414C9CB605C37F20D708BF@SJEXCHMB06.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ariel Elior <ariele@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eilon Greenstein <eilong@broadcom.com>
To: Dmitry Kravkov <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f43.google.com ([209.85.128.43]:51798 "EHLO
	mail-qe0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756163Ab3HMRoW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 13:44:22 -0400
Received: by mail-qe0-f43.google.com with SMTP id k5so4561728qej.30
        for <netdev@vger.kernel.org>; Tue, 13 Aug 2013 10:44:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <504C9EFCA2D0054393414C9CB605C37F20D708BF@SJEXCHMB06.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/08/13 14:16, Dmitry Kravkov wrote:
[...]
> > 
> > Let me rephrase my question:
> > 
> > I'm confused. I thought that "[PATCH net v4 1/6] bnx2x: properly initialize
> > statistic counters" was meant to fix a race condition at driver startup which
> > causes a second statistics query to be sent before the first one completes,
> > resulting in a firmware assert and a stuck chip. Am I mistaken and there is no
> > such race condition, or is it addressed by the other patches in this series?
> > 
> There is such condition, but it's not caused by wrongly initialized counted -
> the initialization done in a correct way. Patch "[PATCH net v5 1/5] bnx2x: protect
> different statistics flows"  - prevents from two outstanding queries to be sent
> simultaneously.

Thank you for the clarification.
