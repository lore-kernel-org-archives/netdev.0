From: jamal <hadi@cyberus.ca>
Subject: Re: few more fixes for iproute2/m_ipt
Date: Wed, 06 Aug 2008 08:55:12 -0400
Message-ID: <1218027312.4755.63.camel@localhost>
References: <200808060042.53503.denys@visp.net.lb>
	 <200808061426.36605.denys@visp.net.lb> <1218026760.4755.60.camel@localhost>
	 <200808061550.42003.denys@visp.net.lb>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.28]:61121 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752735AbYHFMzZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2008 08:55:25 -0400
Received: by yw-out-2324.google.com with SMTP id 9so1740709ywe.1
        for <netdev@vger.kernel.org>; Wed, 06 Aug 2008 05:55:24 -0700 (PDT)
In-Reply-To: <200808061550.42003.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-06-08 at 15:50 +0300, Denys Fedoryshchenko wrote:

> +       /* Clear flags if target will be used again */
> +        m->tflags=0;
> +        m->used=0;
> +       /* Free allocated memory */
> +        if (m->t)
> +            free(m->t);
> + 

I meant moving the above to 02-iproute-optind_zero.patch

No big deal if you dont have time. 

cheers,
jamal

