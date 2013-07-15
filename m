From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [patch net-next RFC 1/3] net: add ndo to get id of physical
 port of the device
Date: Mon, 15 Jul 2013 23:01:57 +0100
Message-ID: <1373925717.3745.24.camel@bwh-desktop.uk.level5networks.com>
References: <1373908027-25800-1-git-send-email-jiri@resnulli.us>
	 <1373908027-25800-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <Narendra_K@Dell.com>,
	<john.r.fastabend@intel.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:64119 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758114Ab3GOWCC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jul 2013 18:02:02 -0400
In-Reply-To: <1373908027-25800-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-07-15 at 19:07 +0200, Jiri Pirko wrote:
> This patch adds a ndo for getting physical port of the device. Driver
> which is aware of being virtual function of some physical port should
> implement this ndo.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>  include/linux/netdevice.h | 18 ++++++++++++++++++
>  1 file changed, 18 insertions(+)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 0741a1e..e85f177 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -728,6 +728,16 @@ struct netdev_fcoe_hbainfo {
>  };
>  #endif
>  
> +#define MAX_PHYS_PORT_ID_LEN 32
> +
> +/* This structure holds a universally unique identifier to
> + * identify the physical port used by a netdevice
[...]

There is a slight problem with saying 'universally unique identifier'
which is that it may be taken to mean specifically a DCE 128-bit UUID.
Is there a slightly more generic term that would clearly allow for other
ID spaces here?  Or should we give a list of examples: 'such as a
128-bit UUID, globally unique MAC-48 or EUI-64'?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
