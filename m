From: =?ISO-8859-2?Q?=A9tefan_Gula?= <steweg@ynet.sk>
Subject: Re: [patch v7, kernel version 3.2.1] net/ipv4/ip_gre: Ethernet
 multipoint GRE over IP
Date: Wed, 1 Feb 2012 00:33:49 +0100
Message-ID: <CAGsizzK+nW=2u89A9wo-q60LstNT_Ujdr511niu9Hv21Uh9+3Q@mail.gmail.com>
References: <12547555.801328015432974.JavaMail.root@5-MeO-DMT.ynet.sk>
 <4168018.821328016111235.JavaMail.root@5-MeO-DMT.ynet.sk> <20120131085612.3bb50a51@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:34758 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753549Ab2AaXeJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2012 18:34:09 -0500
Received: by dadp15 with SMTP id p15so373435dad.19
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2012 15:34:09 -0800 (PST)
In-Reply-To: <20120131085612.3bb50a51@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/1/31 Stephen Hemminger <shemminger@vyatta.com>:
> On Tue, 31 Jan 2012 14:21:51 +0100 (CET)
> Stefan Gula <steweg@ynet.sk> wrote:
>
>> From: Stefan Gula <steweg@gmail.com>
>>
>> This patch is an extension for current Ethernet over GRE
>> implementation, which allows user to create virtual bridge (multipoi=
nt
>> VPN) and forward traffic based on Ethernet MAC address information i=
n
>> it. It simulates the Bridge behavior learning mechanism, but instead
>> of learning port ID from which given MAC address comes, it learns IP
>> address of peer which encapsulated given packet. Multicast, Broadcas=
t
>> and unknown-multicast traffic is send over network as multicast
>> encapsulated GRE packet, so one Ethernet multipoint GRE tunnel can b=
e
>> represented as one single virtual switch on logical level and be als=
o
>> represented as one multicast IPv4 address on network level.
>>
>> Signed-off-by: Stefan Gula <steweg@gmail.com>
>
> Have you looked at the NVGRE standard?
> =A0http://tools.ietf.org/html/draft-sridharan-virtualization-nvgre-00
Yes, I did.
One section from 3.1. NVGRE Endpoint:
To encapsulate an
   Ethernet frame, the endpoint needs to know location information for
   the destination address in the frame. The way to obtain this
   information is not covered in this document and will be covered in a
   different draft. Any number of techniques can be used in the control
   plane to configure, discover and distribute the policy information.
   For the rest of this document we assume that the location
   information including TNI is readily available to the NVGRE
   endpoint.
