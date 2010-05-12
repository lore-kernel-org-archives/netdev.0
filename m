From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] net sched: cleanup and rate limit warning
Date: Wed, 12 May 2010 16:41:43 -0400
Message-ID: <1273696903.16074.25.camel@bigi>
References: <20100511172412.76aff184@nehalam>
	 <1273684674.16074.0.camel@bigi> <20100512111706.616dc7cf@nehalam>
	 <1273691628.16074.15.camel@bigi>  <20100512132042.3b38da18@nehalam>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:52972 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757601Ab0ELUlu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 May 2010 16:41:50 -0400
Received: by fxm4 with SMTP id 4so47958fxm.19
        for <netdev@vger.kernel.org>; Wed, 12 May 2010 13:41:48 -0700 (PDT)
In-Reply-To: <20100512132042.3b38da18@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-05-12 at 13:20 -0700, Stephen Hemminger wrote:

> The tool isn't generating an action (just tc filter ... police ..)
> so it is getting the unfortunate default of reclassify.

Ah ok. 
My advice: you should never ever depend on defaults when you
can be explicit and say "drop". Or have the users in your tool be able
to specify what action to take if rate is exceeded etc (actually i think
juniper does that) 
I think "drop" would be the sane default for over-limit - my memory is
hazy because i assumed that was the default but there may have been some
reservations on that default. Patrick?

cheers,
jamal

