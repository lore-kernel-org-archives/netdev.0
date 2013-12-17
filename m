From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2 net-next] net: vxlan: use custom ndo_change_mtu
 handler
Date: Tue, 17 Dec 2013 13:57:34 -0800
Message-ID: <20131217135734.77ee5916@nehalam.linuxnetplumber.net>
References: <1387312660-3467-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, shahed.shaikh@qlogic.com,
	netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:58027 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752733Ab3LQV5h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 16:57:37 -0500
Received: by mail-pd0-f173.google.com with SMTP id p10so7346079pdj.32
        for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 13:57:36 -0800 (PST)
In-Reply-To: <1387312660-3467-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 17 Dec 2013 21:37:40 +0100
Daniel Borkmann <dborkman@redhat.com> wrote:

> +	struct vxlan_rdst *dst = &vxlan->default_dst;
> +	struct net_device *lowerdev;
> +	int max_mtu;
> +
> +	lowerdev = __dev_get_by_index(dev_net(dev),
> +				      vxlan->default_dst.remote_ifindex);

Actually, I meant that you should use dst->remote_ifindex here.
