From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v2 net-next] net: vxlan: use custom ndo_change_mtu handler
Date: Tue, 17 Dec 2013 22:59:26 +0100
Message-ID: <52B0C93E.6070706@redhat.com>
References: <1387312660-3467-1-git-send-email-dborkman@redhat.com> <20131217135734.77ee5916@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, shahed.shaikh@qlogic.com,
	netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22713 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750966Ab3LQV7e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Dec 2013 16:59:34 -0500
In-Reply-To: <20131217135734.77ee5916@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/17/2013 10:57 PM, Stephen Hemminger wrote:
> On Tue, 17 Dec 2013 21:37:40 +0100
> Daniel Borkmann <dborkman@redhat.com> wrote:
>
>> +	struct vxlan_rdst *dst = &vxlan->default_dst;
>> +	struct net_device *lowerdev;
>> +	int max_mtu;
>> +
>> +	lowerdev = __dev_get_by_index(dev_net(dev),
>> +				      vxlan->default_dst.remote_ifindex);
>
> Actually, I meant that you should use dst->remote_ifindex here.

Ah, okay, was just wondering as it was used in dst->remote_ip.sa.sa_family.

Ok, will do, sure.
