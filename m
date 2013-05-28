From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [patch net-next v2 1/3] net: pass info struct via netdevice
 notifier
Date: Tue, 28 May 2013 08:54:28 +0000 (UTC)
Message-ID: <ko1rc4$nbp$1@ger.gmane.org>
References: <1369729460-28421-1-git-send-email-jiri@resnulli.us>
 <1369729460-28421-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:39135 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933682Ab3E1Iyr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 May 2013 04:54:47 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1UhFg3-0003ax-JA
	for netdev@vger.kernel.org; Tue, 28 May 2013 10:54:43 +0200
Received: from 180.183.220.200 ([180.183.220.200])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 28 May 2013 10:54:43 +0200
Received: from xiyou.wangcong by 180.183.220.200 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 28 May 2013 10:54:43 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 28 May 2013 at 08:24 GMT, Jiri Pirko <jiri@resnulli.us> wrote:
>  simeth_device_event(struct notifier_block *this,unsigned long event, void *ptr)
>  {
> -	struct net_device *dev = ptr;
> +	struct net_device *dev = get_netdevice_nofifier_info_dev(ptr);

typo above....

BTW, get_netdevice_notifier_info_dev() really sucks, can we make it
shorter? For example, notifier_into_to_dev()?

Thanks.
