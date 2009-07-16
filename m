From: Ben Greear <greearb@candelatech.com>
Subject: Re: Determine veth peer device?
Date: Thu, 16 Jul 2009 10:45:38 -0700
Message-ID: <4A5F6742.6050309@candelatech.com>
References: <4A5E6C5E.1070808@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:50719 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932603AbZGPRpj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2009 13:45:39 -0400
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id n6GHjcEK032701
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 16 Jul 2009 10:45:38 -0700
In-Reply-To: <4A5E6C5E.1070808@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/15/2009 04:55 PM, Ben Greear wrote:
> Is there a way to determine the peer device for a
> veth interface in user-space?
>
> I didn't see anything obvious printed in 'ip link show'
>
> [root@i7-1qc-1 ~]# ip link show dev veth0
> 7: veth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
> state UP qlen 1000
> link/ether 72:2e:4d:74:5b:a6 brd ff:ff:ff:ff:ff:ff

For the record, can get it via ethtool ioctl:

[root@i7-1qc-1 ~]# ethtool -S veth1
NIC statistics:
      peer_ifindex: 7

Take it easy,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

