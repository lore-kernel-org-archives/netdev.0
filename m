From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] SSB PCI core driver fixes
Date: Thu, 9 Aug 2007 02:27:06 +0200
Message-ID: <200708090227.06510.mb@bu3sch.de>
References: <20070809002353.GA4594@hall.aurel32.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Aurelien Jarno <aurelien@aurel32.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:43554
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763669AbXHIA1I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2007 20:27:08 -0400
In-Reply-To: <20070809002353.GA4594@hall.aurel32.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 09 August 2007, Aurelien Jarno wrote:
>  - Add some delay between the configuration of the PCI controller 
>    and its registration.

Why? It is _huge_ and people won't like it ;)
At least add a comment why this is needed.

> @@ -340,6 +345,7 @@
>  	 * The following needs change, if we want to port hostmode
>  	 * to non-MIPS platform. */
>  	set_io_port_base((unsigned long)ioremap_nocache(SSB_PCI_MEM, 0x04000000));
> +	mdelay(300);
>  	register_pci_controller(&ssb_pcicore_controller);
>  }
> 


