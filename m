From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-2.6.26 4/10][VLAN]: Introduce the vlan_net structure
 and init/exit net ops.
Date: Tue, 15 Apr 2008 14:09:24 +0200
Message-ID: <48049AF4.1000704@trash.net>
References: <4804989F.1060503@openvz.org> <48049A71.1030900@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35402 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751324AbYDOMJd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 08:09:33 -0400
In-Reply-To: <48049A71.1030900@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov wrote:
> @@ -632,6 +670,10 @@ static int __init vlan_proto_init(void)
>  	pr_info("%s v%s %s\n", vlan_fullname, vlan_version, vlan_copyright);
>  	pr_info("All bugs added by %s\n", vlan_buggyright);
>  
> +	err = register_pernet_gen_device(&vlan_net_id, &vlan_net_ops);
> +	if (err < 0)
> +		goto err0;

I'm wondering what vlan_net_id is used for, but I can't find that
function in the current net-2.6.26.git tree. What tree are these
patches based on?
