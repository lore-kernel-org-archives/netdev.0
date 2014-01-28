From: zhuyj <zyjzyj2000@gmail.com>
Subject: Re: How to identify 6to4 and 6in4 tunnels
Date: Tue, 28 Jan 2014 15:39:17 +0800
Message-ID: <52E75EA5.4070102@gmail.com>
References: <52E63779.5090101@gmail.com> <52E65817.1090904@6wind.com> <52E75D23.10909@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: nicolas.dichtel@6wind.com, "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	linux-kernel@vger.kernel.org, zhuyj <zyjzyj2000@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f169.google.com ([209.85.216.169]:44857 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754706AbaA1Hj0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jan 2014 02:39:26 -0500
In-Reply-To: <52E75D23.10909@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/28/2014 03:32 PM, zhuyj wrote:
> On 01/27/2014 08:59 PM, Nicolas Dichtel wrote:
>> Le 27/01/2014 11:39, zhuyj a =E9crit :
>>> Hi, Maintainers
>>>
>>> In our scene, we will create the 6in4/6to4 tunnel firstly and need=20
>>> to check the
>>> tunnel type, secondly, we will configure the ip address on it. So,=20
>>> Could we have
>>> any way to get the actual tunnel for 6in4 and 6to4 from current=20
>>> linux version?
>>>
>>> Both 6in4 and 6to4 have the same protocol =93IPPROTO_IPV6=94 in Lin=
ux=20
>>> kernel. The
>>> only difference is the ip address on the tunnel. Can we distinguish=
=20
>>> them in
>>> Linux kernel?
>> Just check the prefix, like it is done in check_6rd().
>>
>>
>> Regards,
>> Nicolas
Hi, Nicolas
Thanks for your reply. Maybe I can configure 6to4 tunnel by the=20
following commands:

  ip tunnel add tun6to4 mode sit remote any local 1.202.252.122 ttl 64
  ip link set dev tun6to4 up
  ip -6 addr add 2002:01ca:fc7a::0012:0225:2122/128 dev tun6to4
  ip -6 route add 2000::/3 via ::192.88.99.1 dev tun6to4 metric 1

But the kernel can not identify the tunnel is 6to4 tunnel or 6in4 tunne=
l=20
immediately. After the packets travel through this tunnel, the kernel=20
can identify the type of the tunnel by check_6rd.

Is it right?

Best Regards!
Zhu Yanjun
