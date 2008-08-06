From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: iproute2/m_ipt fix, opts was not set properly
Date: Wed, 6 Aug 2008 14:02:00 +0300
Message-ID: <200808061402.01021.denys@visp.net.lb>
References: <200808052224.36773.denys@visp.net.lb> <1218019350.4755.30.camel@localhost> <1218019945.4755.36.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:45653 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754013AbYHFLCt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2008 07:02:49 -0400
In-Reply-To: <1218019945.4755.36.camel@localhost>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 06 August 2008, jamal wrote:
> 1. change free_opts to be:
>
> static void free_opts(struct option **opts)
> {
>         if (*opts != original_opts) {
>                 free(*opts);
>                 *opts = original_opts;
>         }
> }
>
> 2. Change invocations of free_opts to be:
>
> free_opts(&opts);
>
> cheers,
> jamal
Does it work on my test batch?
Your way looks much more clean :-)
(I cannot test it properly, since i have modified iproute2 now)

