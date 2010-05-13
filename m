From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] net sched: cleanup and rate limit warning
Date: Thu, 13 May 2010 12:20:26 -0400
Message-ID: <1273767626.6117.3.camel@bigi>
References: <20100511172412.76aff184@nehalam>
	 <1273684674.16074.0.camel@bigi> <20100512111706.616dc7cf@nehalam>
	 <1273691628.16074.15.camel@bigi>  <20100512132042.3b38da18@nehalam>
	 <1273696903.16074.25.camel@bigi>  <4BEBFAD4.1030608@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:42772 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757101Ab0EMQUc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 May 2010 12:20:32 -0400
Received: by wwi18 with SMTP id 18so1004367wwi.19
        for <netdev@vger.kernel.org>; Thu, 13 May 2010 09:20:31 -0700 (PDT)
In-Reply-To: <4BEBFAD4.1030608@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-05-13 at 15:12 +0200, Patrick McHardy wrote:

> I don't remeber ever discussing that, the choice of "reclassify" as
> default precedes TC actions and is already present in the oldest
> iproute2 version I could find (2.2.4-ss000225).

I think i confused it with unrelated discussion.

If its been there from day 0 then we should leave it as is - rationale:
it will help to catch config bugs.
Stephen needs to fix his tool regardless...

cheers,
jamal

