From: zhuyj <zyjzyj2000@gmail.com>
Subject: Re: Aw: IP-Packets over wrong Ethernet device
Date: Thu, 03 Jul 2014 13:39:39 +0800
Message-ID: <53B4EC9B.70503@gmail.com>
References: <trinity-115b0f38-53ca-4333-9f3d-0cca5ea770d9-1403251544932@3capp-webde-bs53> <trinity-e658ef1e-b2fd-4ed2-8b80-4056c6fb2901-1403252543405@3capp-webde-bs53>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: =?UTF-8?B?Q29uY2jDunIgTmF2aWQ=?= <conchur@web.de>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:47818 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752807AbaGCFjl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2014 01:39:41 -0400
Received: by mail-pd0-f181.google.com with SMTP id v10so13218373pde.40
        for <netdev@vger.kernel.org>; Wed, 02 Jul 2014 22:39:40 -0700 (PDT)
In-Reply-To: <trinity-e658ef1e-b2fd-4ed2-8b80-4056c6fb2901-1403252543405@3capp-webde-bs53>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/20/2014 04:22 PM, "Conch=C3=BAr Navid" wrote:
>> A dump on the management network ethernet interface (192.168.1.x/24)=
 shows me that there was really an ARP request of the sender for 192.16=
8.200.x/24 on this interface which was replied by the receiver on that =
interface. Is there a way to disable this reply on the "wrong" interfac=
e without using ARP-tables?
> This is done by setting arp_ignore to 2 in sysctl (for the correct in=
terfaces):
>
> sysctl -a|grep arp_ignore
> sysctl -w net.ipv4.conf.eth5.arp_ignore=3D2
This is explained in Linux Network Internal, 28.5.2.2. ARP_IGNORE

2  Like 1, but the source IP (sender's address) must belong to the same=
=20
subnet as the target IP.

Zhu Yanjun
> Thanks
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
