From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [stable] [BUG] net: fix /proc/net/snmp as memory corruptor
Date: Sat, 15 Nov 2008 06:25:33 +0100
Message-ID: <491E5D4D.1080800@cosmosbay.com>
References: <491D07E0.9010903@cosmosbay.com> <20081115051015.GB26468@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: stable@kernel.org, "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:43343 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755505AbYKOFZt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Nov 2008 00:25:49 -0500
In-Reply-To: <20081115051015.GB26468@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greg KH a =E9crit :
> On Fri, Nov 14, 2008 at 06:08:48AM +0100, Eric Dumazet wrote:
>> Hello Greg
>>
>> A patch was submited about /proc/net/snmp being a memory corruptor a=
nd not SMP safe
>>
>> (commit b971e7ac834e9f4bda96d5a96ae9abccd01c1dd8)
>>
>> These bugs are present on 2.6.26 & 2.6.27.
>=20
> I looking at this, it doesn't seem to apply at all to the .27 tree.  =
If
> David doesn't object, care to backport it there and send it to
> stable@kernel.org?
>=20

Strange... I just tried to apply patch on top of a fresh linux-2.6.27.6=
 tree and got no error

# patch -p1 < /tmp/icmp_snmp.patch
patching file net/ipv4/proc.c
#



