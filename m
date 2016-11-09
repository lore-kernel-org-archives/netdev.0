From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v2 5/7] vxlan: simplify RTF_LOCAL handling.
Date: Wed, 9 Nov 2016 17:53:22 +0100
Message-ID: <20161109175322.57c9b860@griffin>
References: <1478371557-71888-1-git-send-email-pshelar@ovn.org>
        <1478371557-71888-6-git-send-email-pshelar@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41786 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752509AbcKIQx0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Nov 2016 11:53:26 -0500
In-Reply-To: <1478371557-71888-6-git-send-email-pshelar@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat,  5 Nov 2016 11:45:55 -0700, Pravin B Shelar wrote:
> +static int check_route_rtf_local(struct sk_buff *skb, struct net_device *dev,
> +				 struct vxlan_dev *vxlan, union vxlan_addr *daddr,
> +				 __be32 dst_port, __be32 vni, struct dst_entry *dst,
> +				 u32 rt_flags)

It's not just checking, it's also bypassing encapsulation if the check
is successful. Would be good to use a name that suggests this effect,
e.g. encap_bypass_if_local (I know, not a nice name) or something.

Thanks,

 Jiri
