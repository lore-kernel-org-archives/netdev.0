From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [BUG net-next-2.6] Had to revert bonding: allow arp_ip_targets on
	separate vlans to use arp validation
Date: Wed, 6 Jan 2010 16:45:38 -0500
Message-ID: <7b667921001061345v1edd07abkae1fcbbabe604156@mail.gmail.com>
References: <4B44258C.2050302@gmail.com> <4B44D89B.8070006@gmail.com>
	 <4B44FC2B.4090505@gmail.com>
	 <20100106.133811.207901772.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, therbert@google.com,
	netdev@vger.kernel.org, fubar@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f194.google.com ([209.85.223.194]:54703 "EHLO
	mail-iw0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755706Ab0AFVpj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2010 16:45:39 -0500
Received: by iwn32 with SMTP id 32so1895903iwn.33
        for <netdev@vger.kernel.org>; Wed, 06 Jan 2010 13:45:39 -0800 (PST)
In-Reply-To: <20100106.133811.207901772.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 6, 2010 at 4:38 PM, David Miller <davem@davemloft.net> wrot=
e:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 06 Jan 2010 22:10:03 +0100
>
>> Le 06/01/2010 19:38, Eric Dumazet a =E9crit :
>>>
>>> (net-next-2.6 doesnt work well on my bond/vlan setup, I suspect I n=
eed a bisection)
>>
>> David, I had to revert 1f3c8804acba841b5573b953f5560d2683d2db0d
>> (bonding: allow arp_ip_targets on separate vlans to use arp validati=
on)
>>
>> Or else, my vlan devices dont work (unfortunatly I dont have much ti=
me
>> these days to debug the thing)
>
> I bet this is the same issue Jay was running into, and he
> ACK'd the patch anyways. :-)
>
> This is why I wanted full testing and feedback before committing this
> change.
>
> Unless I see a fix in the next day I'm reverting from net-next-2.6
>
>

Seems reasonable.  I'm working on it now trying to understand what
might be different about my setup and why I'm not seeing any problems.
