From: "Oleg V. Ukhno" <olegu@yandex-team.ru>
Subject: Re: [PATCH] bonding: added 802.3ad round-robin hashing policy for
 single TCP session balancing
Date: Thu, 03 Feb 2011 17:54:38 +0300
Message-ID: <4D4AC1AE.70809@yandex-team.ru>
References: <20110114190714.GA11655@yandex-team.ru> <17405.1295036019@death> <4D30D37B.6090908@yandex-team.ru> <26330.1295049912@death> <4D35060D.5080004@intel.com> <4D358A47.4020009@yandex-team.ru> <4D35A9B4.7030701@gmail.com> <4D35B1B0.2090905@yandex-team.ru> <4D35BED5.7040301@gmail.com> <28837.1295382268@death> <4D370DC7.6000500@yandex-team.ru> <4D3745AF.5040808@gmail.com> <4D399062.3060004@yandex-team.ru> <19551.1296268113@death> <4D4929BB.2000403@gmail.com> <32505.1296669453@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from archeopterix.yandex.ru ([93.158.136.52]:58193 "EHLO
	archeopterix.yandex.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755844Ab1BCOyk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Feb 2011 09:54:40 -0500
In-Reply-To: <32505.1296669453@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/02/2011 08:57 PM, Jay Vosburgh wrote:
> Nicolas de Peslo=C3=BCan<nicolas.2p.debian@gmail.com>  wrote:

>> I just propose the following option and option values : "src_mac_sel=
ect"
>> (instead of mac_select), with "default" and "slave_mac" (instead of
>> slave_src_mac) as possible values. In the future, we might need a
>> "dst_mac_select" option... :-)
>
> 	I originally thought of using the nomenclature you propose; my
> thinking for doing it the way I ended up with is to minimize the numb=
er
> of tunable knobs that bonding has (so, the dst_mac would be a setting
> for mac_select).  That works as long as there aren't a lot of setting=
s
> that would be turned on simultaneously, since each combination would
> have to be a separate option, or the options parser would have to han=
dle
> multiple settings (e.g., mac_select=3Dsrc+dst or something like that)=
=2E
>
> 	Anyway, after thinking about it some more, in the long run it's
> probably safer to separate these two, so, Oleg, use the above naming
> ("src_mac_select" with "default" and "slave_mac").
>
>> Also, are there any risks that this kind of session load-balancing w=
on't
>> properly cooperate with multiqueue (as explained in "Overriding
>> Configuration for Special Cases" in Documentation/networking/bonding=
=2Etxt)?
>> I think it is important to ensure we keep the ability to fine tune t=
he
>> egress path selection
>
> 	I think the logic for the mac_select (or src_mac_select or
> whatever) just has to be done last, after the slave selection is done=
 by
> the multiqueue stuff.  That's probably a good tidbit to put in the
> documentation as well.
>
> 	-J
>
> ---
> 	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
Thank everyone for comments,
I'll resubmit modified patch after it is ready and tested, in about a=20
week or two  I think.

Oleg

>


--=20
Best regards,
Oleg Ukhno

