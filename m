From: Fernando Luis Vazquez Cao <fernando_b1@lab.ntt.co.jp>
Subject: Re: [PATCH] vlan: restore ethtool ABI to control VLAN hardware acceleration
Date: Tue, 18 Jun 2013 10:38:14 +0900
Message-ID: <51BFBA06.7050901@lab.ntt.co.jp>
References: <1371436083.7579.1.camel@nexus> <1371493254.2086.64.camel@bwh-desktop.uk.level5networks.com> <20130617.171001.1255646251913428917.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bhutchings@solarflare.com, kaber@trash.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:59062 "EHLO
	tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753493Ab3FRBi3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jun 2013 21:38:29 -0400
In-Reply-To: <20130617.171001.1255646251913428917.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013=E5=B9=B406=E6=9C=8818=E6=97=A5 09:10, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Mon, 17 Jun 2013 19:20:54 +0100
>
>> On Mon, 2013-06-17 at 11:28 +0900, Fernando Luis V=C3=A1zquez Cao wr=
ote:
>>> As part of the push to add 802.1ad server provider tagging support =
to the
>>> kernel the VLAN features flags were renamed. Unfortunately the kern=
el name
>>> for the VLAN hardware acceleration features that the kernel shows u=
ser space
>>> was included in the rename, which broke ethtool (txvlan and rxvlan =
options
>>> do not work).
>> I expected something like that and said this was an ABI change, but
>> apparently my objection wasn't sufficient.
>>
>>> This patch restores the original names, i.e. the original ABI.
>>> If we wanted to make clear to users that we are refering to CTAGs w=
e can
>>> always change ethtool's short_name and long_name for these features=
 (for
>>> example something along the lines of txvlan -> txvlan-ctag, tx-vlan=
-offload ->
>>> tx-vlan-ctag-offload).
>>>
>>> Cc: Patrick McHardy <kaber@trash.net>
>>> Cc: David S. Miller <davem@davemloft.net>
>>> Cc: netdev@vger.kernel.org
>>> Signed-off-by: Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>
>> Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>
> Ok Ben you were indeed right :-)
>
> Applied, thanks.

Could you get this to Linus before 3.10 is out?

Thanks,
=46ernando
