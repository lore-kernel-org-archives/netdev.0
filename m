From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 1/3] net: pass info struct via netdevice notifier
Date: Tue, 28 May 2013 10:22:31 +0200
Message-ID: <20130528082231.GA1536@minipsycho.orion>
References: <1369728655-26649-1-git-send-email-jiri@resnulli.us>
 <1369728655-26649-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, eric.dumazet@gmail.com, timo.teras@iki.fi,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, bhutchings@solarflare.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f179.google.com ([74.125.82.179]:35619 "EHLO
	mail-we0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933415Ab3E1IWf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 04:22:35 -0400
Received: by mail-we0-f179.google.com with SMTP id m46so5129219wev.10
        for <netdev@vger.kernel.org>; Tue, 28 May 2013 01:22:33 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1369728655-26649-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>+static int call_netdevice_notifier(struct notifier_block *nb, unsigned long val,
>+				   struct net_device *dev)
>+{
>+	struct netdevice_notifier_info info;
>+
>+	init_netdevice_notifier_info(&info, dev);
>+	return nb->notifier_call(nb, NETDEV_REGISTER, &info);

oops - will fix this and post v2
