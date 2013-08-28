From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [net-next  1/2] vxlan: Notify drivers for listening UDP port
 changes
Date: Wed, 28 Aug 2013 07:47:35 +0000 (UTC)
Message-ID: <kvk9um$j48$1@ger.gmane.org>
References: <1377665218-6760-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:53278 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751897Ab3H1HsD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Aug 2013 03:48:03 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1VEaTy-0006He-4J
	for netdev@vger.kernel.org; Wed, 28 Aug 2013 09:48:02 +0200
Received: from 36.58.190.45 ([36.58.190.45])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 28 Aug 2013 09:48:02 +0200
Received: from xiyou.wangcong by 36.58.190.45 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 28 Aug 2013 09:48:02 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 28 Aug 2013 at 04:46 GMT, Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:
> From: Joseph Gasparakis <joseph.gasparakis@intel.com>
>
> This patch adds two more ndo ops: ndo_add_rx_vxlan_port() and
> ndo_del_rx_vxlan_port().
>
> Drivers can get notifications through the above functions about changes
> of the UDP listening port of VXLAN. Also, when physical ports come up,
> now they can call vxlan_get_rx_port() in order to obtain the port number(s)
> of the existing VXLAN interface in case they already up before them.
>
> This information about the listening UDP port would be used for VXLAN
> related offloads.
>

Since this is a notification, how about adding a new NETDEV_* event
rather than adding two new ndo_* ops?
