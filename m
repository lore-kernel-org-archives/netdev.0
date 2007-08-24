From: Al Viro <viro@ftp.linux.org.uk>
Subject: Re: [PATCH] via-velocity: use standard VLAN interface (resend)
Date: Fri, 24 Aug 2007 22:15:47 +0100
Message-ID: <20070824211547.GW21089@ftp.linux.org.uk>
References: <20070824135649.509e1fe7@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:53552 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752086AbXHXVQU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2007 17:16:20 -0400
Content-Disposition: inline
In-Reply-To: <20070824135649.509e1fe7@freepuppy.rosehill.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 24, 2007 at 01:56:49PM -0700, Stephen Hemminger wrote:

>  static void velocity_init_cam_filter(struct velocity_info *vptr)
>  {
>  	struct mac_regs __iomem * regs = vptr->mac_regs;
> +	unsigned short vid;
  
> -		mac_set_cam(regs, 0, (u8 *) & (vptr->options.vid), VELOCITY_VLAN_ID_CAM);
> +				mac_set_cam(regs, 0, (u8 *) &vid,
> +					    VELOCITY_VLAN_ID_CAM);

This mac_set_cam() dreck should be split in two properly typed functions.
