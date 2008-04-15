From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH net-2.6.26 4/10][VLAN]: Introduce the vlan_net structure
 and init/exit net ops.
Date: Tue, 15 Apr 2008 16:50:20 +0400
Message-ID: <4804A48C.5070102@openvz.org>
References: <4804989F.1060503@openvz.org> <48049A71.1030900@openvz.org> <48049AF4.1000704@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:40742 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752612AbYDOMQS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 08:16:18 -0400
In-Reply-To: <48049AF4.1000704@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> Pavel Emelyanov wrote:
>> @@ -632,6 +670,10 @@ static int __init vlan_proto_init(void)
>>  	pr_info("%s v%s %s\n", vlan_fullname, vlan_version, vlan_copyright);
>>  	pr_info("All bugs added by %s\n", vlan_buggyright);
>>  
>> +	err = register_pernet_gen_device(&vlan_net_id, &vlan_net_ops);
>> +	if (err < 0)
>> +		goto err0;
> 
> I'm wondering what vlan_net_id is used for, but I can't find that
> function in the current net-2.6.26.git tree. What tree are these
> patches based on?
> 

They are for net-2.6.26 with this
http://marc.info/?l=linux-netdev&m=120799367318572&w=2
and this
http://marc.info/?l=linux-netdev&m=120799357618440&w=2
patches.

David said the he accepted them both and agreed that I send
other work based on them.

Thanks,
Pavel
