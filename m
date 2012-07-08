From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next patch] bnx2x: Add run-time CNIC support
Date: Sun, 08 Jul 2012 13:14:03 +0200
Message-ID: <1341746043.3265.1653.camel@edumazet-glaptop>
References: <1341740914-3181-1-git-send-email-meravs@broadcom.com>
	 <20120708.033122.2108511545126626834.davem@davemloft.net>
	 <1341745239.27284.13.camel@lb-tlvb-meravs.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	eilong@broadcom.com, dmitry@broadcom.com
To: Merav Sicron <meravs@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:35014 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750748Ab2GHLOH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Jul 2012 07:14:07 -0400
Received: by wgbdr13 with SMTP id dr13so10576043wgb.1
        for <netdev@vger.kernel.org>; Sun, 08 Jul 2012 04:14:06 -0700 (PDT)
In-Reply-To: <1341745239.27284.13.camel@lb-tlvb-meravs.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-07-08 at 14:00 +0300, Merav Sicron wrote:

> static int set_is_cnic_enabled(bool is_vf)
> {
>         if (is_vf)
>                 return 0;
> #if defined(CONFIG_CNIC) || defined(CONFIG_CNIC_MODULE)
>         return 1;
> #else
>         return 0;
> #endif
> }

Small note : this should use booleans and can use

if (is_vf)
	return false;

return IS_ENABLED(CONFIG_CNIC);
