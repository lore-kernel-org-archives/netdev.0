From: Torsten Schmidt <torsten.schmidt@s2006.tu-chemnitz.de>
Subject: Re: Still using IPTOS_TOS() in kernel? Really???
Date: Tue, 5 Jan 2010 16:35:59 +0100
Message-ID: <201001051635.59914.schmto@hrz.tu-chemnitz.de>
References: <4B298118.2000608@redfish-solutions.com> <200912221328.56573.schmto@hrz.tu-chemnitz.de> <4B32A33C.6050507@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: "Philip A. Prindeville" <philipp_subx@redfish-solutions.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from jack.hrz.tu-chemnitz.de ([134.109.132.46]:56299 "EHLO
	jack.hrz.tu-chemnitz.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752837Ab0AEPgL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 10:36:11 -0500
In-Reply-To: <4B32A33C.6050507@redfish-solutions.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Can you extend the patch to include classify_1d() in net/mac80211/wme.c?
> 
> I'm thinking:
> 
>          }
> 
> -        if (dscp & 0x1c)
> +#if !defined(CONFIG_IP_DIFFSERV_COMPLIANT)
> +        if (IPTOS_TOS(dscp) & ~IPTOS_LOWCOST)
>                  return 0;
> +#endif
>          return dscp >> 5;
>  }
This code segment seems to be older stuff. Its not in 2.6.32. 

Torsten 
