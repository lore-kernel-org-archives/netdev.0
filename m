From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next V6 06/14] bridge: Add netlink interface to
 configure vlans on bridge ports
Date: Thu, 17 Jan 2013 04:54:37 +0000 (UTC)
Message-ID: <kd806c$ptv$2@ger.gmane.org>
References: <1358360289-23249-1-git-send-email-vyasevic@redhat.com>
 <1358360289-23249-7-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:38918 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758696Ab3AQEzA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jan 2013 23:55:00 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1TvhVR-0000QF-VF
	for netdev@vger.kernel.org; Thu, 17 Jan 2013 05:55:13 +0100
Received: from 222.221.64.75 ([222.221.64.75])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 17 Jan 2013 05:55:13 +0100
Received: from xiyou.wangcong by 222.221.64.75 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 17 Jan 2013 05:55:13 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 16 Jan 2013 at 18:18 GMT, Vlad Yasevich <vyasevic@redhat.com> wrote:
> +
> +struct bridge_vlan_info {
> +	u16 flags;
> +	u16 vid;
> +};

I think you have to use __u16 in UAPI headers.
