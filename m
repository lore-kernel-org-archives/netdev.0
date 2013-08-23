From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 1/2] Documentation/networking/: Update Intel wired
 LAN driver documentation
Date: Fri, 23 Aug 2013 13:53:39 +0100
Message-ID: <1377262419.3364.11.camel@bwh-desktop.uk.level5networks.com>
References: <1377260961-10096-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<gospo@redhat.com>, <sassmann@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:34234 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755383Ab3HWMxn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Aug 2013 08:53:43 -0400
In-Reply-To: <1377260961-10096-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-08-23 at 05:29 -0700, Jeff Kirsher wrote:
> Updates the documentation to the Intel wired LAN drivers.

Except e100.txt which seems to be moving backward in time:

[...]
> --- a/Documentation/networking/e100.txt
> +++ b/Documentation/networking/e100.txt
> @@ -1,7 +1,7 @@
>  Linux* Base Driver for the Intel(R) PRO/100 Family of Adapters
>  ==============================================================
>  
> -November 15, 2005
> +March 15, 2011
>  
>  Contents
>  ========
> @@ -94,8 +94,8 @@ Additional Configurations
>  
>    Configuring a network driver to load properly when the system is started is
>    distribution dependent. Typically, the configuration process involves adding
> -  an alias line to /etc/modprobe.d/*.conf as well as editing other system
> -  startup scripts and/or configuration files.  Many popular Linux
> +  an alias line to /etc/modules.conf or /etc/modprobe.conf as well as editing

Reverting this fix:

commit 970e2486492aa1eb47a436a5a4c81e92558986a9
Author: Lucas De Marchi <lucas.demarchi@profusion.mobi>
Date:   Fri Mar 30 13:37:16 2012 -0700

    Documentation: remove references to /etc/modprobe.conf

[...]
>    Enabling Wake on LAN* (WoL)
>    ---------------------------
> -  WoL is provided through the ethtool* utility.  For instructions on enabling
> -  WoL with ethtool, refer to the ethtool man page.
> +  WoL is provided through the ethtool* utility. The ethtool utility is included
> +  with Red Hat* 8.0. For other Linux distributions, download and install
[...]

And part of this one:

commit 68f20d948c86bd6bbc075052f6b6c45b8f56957e
Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date:   Fri Dec 17 12:14:34 2010 +0000

    Documentation/networking: Update Intel Wired LAN docs

Mentioning a 2002 distribution is completely pointless.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
