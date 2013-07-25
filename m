From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next v3 6/6] openvswitch: Add vxlan tunneling support.
Date: Thu, 25 Jul 2013 06:44:24 +0000 (UTC)
Message-ID: <ksqhg8$jej$1@ger.gmane.org>
References: <1374688857-14427-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:44910 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751194Ab3GYGos (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jul 2013 02:44:48 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1V2FI3-0007tA-3o
	for netdev@vger.kernel.org; Thu, 25 Jul 2013 08:44:43 +0200
Received: from 119.6.80.230 ([119.6.80.230])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 25 Jul 2013 08:44:43 +0200
Received: from xiyou.wangcong by 119.6.80.230 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 25 Jul 2013 08:44:43 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 24 Jul 2013 at 18:00 GMT, Pravin B Shelar <pshelar@nicira.com> wrote:
> +
> +config OPENVSWITCH_VXLAN
> +	bool "Open vSwitch VXLAN tunneling support"
> +	depends on INET
> +	depends on OPENVSWITCH
> +	depends on VXLAN && !(OPENVSWITCH=y && VXLAN=m)

This seems ugly, is it possible to make these vxlan code be a library as
iptunnel code?
