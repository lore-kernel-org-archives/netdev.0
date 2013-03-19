From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH v2 net-next 1/5] GRE: Refactor GRE tunneling code.
Date: Tue, 19 Mar 2013 11:31:30 +0100
Message-ID: <87r4jb1y0t.fsf@nemi.mork.no>
References: <1363630405-1672-1-git-send-email-pshelar@nicira.com>
	<20130318122409.00c01106@nehalam.linuxnetplumber.net>
	<20130318.153319.206719819832403477.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: stephen@networkplumber.org, pshelar@nicira.com,
	netdev@vger.kernel.org, jesse@nicira.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:46770 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750773Ab3CSKbr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 06:31:47 -0400
In-Reply-To: <20130318.153319.206719819832403477.davem@davemloft.net> (David
	Miller's message of "Mon, 18 Mar 2013 15:33:19 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:
> From: Stephen Hemminger <stephen@networkplumber.org>
>> On Mon, 18 Mar 2013 11:13:25 -0700
>> Pravin B Shelar <pshelar@nicira.com> wrote:
>>=20
>>> diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
>>> index 7944df7..2073226 100644
>>> --- a/net/ipv4/Kconfig
>>> +++ b/net/ipv4/Kconfig
>>> @@ -186,9 +186,14 @@ config NET_IPGRE_DEMUX
>>>  	 This is helper module to demultiplex GRE packets on GRE version =
field criteria.
>>>  	 Required by ip_gre and pptp modules.
>>> =20
>>> +config NET_IP_TUNNEL
>>> +	tristate
>>> +	default n
>>> +
>>=20
>> Won't this break existing kernel config's, shouldn't this default y?
>
> Or "m".  But indeed, it should be made to automatically work for
> existing configs.

Won't the "select NET_IP_TUNNEL" statements do just that?

Changing the default to m will enable this module even if all of
NET_IPGRE, VXLAN and NET_IPIP are disabled. That's pointless, isn't it?



Bj=C3=B8rn
