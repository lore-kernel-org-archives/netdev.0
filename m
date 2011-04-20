From: Ben Greear <greearb@candelatech.com>
Subject: Re: r8169 doesn't report link state correctly.
Date: Wed, 20 Apr 2011 14:56:46 -0700
Message-ID: <4DAF569E.1040507@candelatech.com>
References: <4DA35FEF.1030009@candelatech.com> <20110413174815.GB17579@electric-eye.fr.zoreil.com> <20110420191403.GC18805@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:42125 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752740Ab1DTV4w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 17:56:52 -0400
In-Reply-To: <20110420191403.GC18805@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/20/2011 12:14 PM, Francois Romieu wrote:
> Fran=C3=A7ois Romieu<romieu@fr.zoreil.com>  :
>> On Mon, Apr 11, 2011 at 01:09:19PM -0700, Ben Greear wrote:
>>> I notice that in kernel 2.6.38-wl, the realtek 8169 NIC doesn't
>>> report link down when in fact there is no cable connected.  Instead=
,
> [...]
>> Thanks for the report. I'll try it tomorrow or friday.
>
> I have not been able to notice it with a current kernel.
>
> I'd welcome the XID of the 8169 NIC (see dmesg) and a short explanati=
on
> (no cable from boot ? cable removed after ifconfig up ? brand / abili=
ty
> of the switch / hub ?).

Well, as luck would have it, my system will boot today's upstream
kernel (39-rc4+).  And, I no longer see the problem in that release,
so it seems it is fixed (or harder to reproduce that I thought).

Basically, I was seeing it claim to have link in 'ethtool' output
when there was no cable connected.  It did go to 10Mbps/half duplex
link speed when un-plugged.  It showed full 1Gbps link when plugged
in.

I'll let you know if I see this again.

Thanks,
Ben

>
> Thanks.
>


--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

