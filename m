From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][CAN]: Fix copy_from_user() results interpretation
Date: Sat, 26 Apr 2008 03:01:46 -0700 (PDT)
Message-ID: <20080426.030146.227030606.davem@davemloft.net>
References: <4812E73A.6060104@hartkopp.net>
	<20080426.021001.18044508.davem@davemloft.net>
	<20080426095923.GA22836@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oliver@hartkopp.net, wg@grandegger.com,
	urs.thuermann@volkswagen.de, netdev@vger.kernel.org,
	socketcan-core@lists.berlios.de, oliver.hartkopp@volkswagen.de,
	xemul@openvz.org
To: sam@ravnborg.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53891
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751826AbYDZKBt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2008 06:01:49 -0400
In-Reply-To: <20080426095923.GA22836@uranus.ravnborg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sam Ravnborg <sam@ravnborg.org>
Date: Sat, 26 Apr 2008 11:59:23 +0200

> diff --git a/scripts/Makefile.build b/scripts/Makefile.build
> index 277cfe0..4a7327b 100644
> --- a/scripts/Makefile.build
> +++ b/scripts/Makefile.build
> @@ -105,7 +105,7 @@ endif
>  
>  # Do section mismatch analysis for each module/built-in.o
>  ifdef CONFIG_DEBUG_SECTION_MISMATCH
> -  cmd_secanalysis = ; scripts/mod/modpost $@
> +  #cmd_secanalysis = ; scripts/mod/modpost $@
>  endif
>  
>  # Compile C sources (.c)

What's this? :-)
