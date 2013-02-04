From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: Re: Gianfar : Q : Tx VLAN hardware accelaration
Date: Mon, 4 Feb 2013 12:04:07 +0200
Message-ID: <510F8797.10909@freescale.com>
References: <001401ce0060$e686afd0$b3940f70$@acksys.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: voncken <cedric.voncken@acksys.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe002.messaging.microsoft.com ([213.199.154.140]:55424
	"EHLO db3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751085Ab3BDKEZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2013 05:04:25 -0500
In-Reply-To: <001401ce0060$e686afd0$b3940f70$@acksys.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/1/2013 11:45 AM, voncken wrote:
> 	Hi Claudiu,
>
> I would like to send on the same Ethernet interface (so the same eTSEC) a
> frame with VLAN tag and without VLAN tag.
>
> If I understand correctly mpc8315 Family reference manual rev 2, when TX
> VLAN hardware acceleration is enable, the eTSEC always add the VLAN TAG
> -from FCB or from the default TAG register).
>
> Could you confirm is not possible to send frame without tag when Tx VLAN
> hardware acceleration is enable?
>
> Thanks
>

Hi Cedric,
If I remember correctly, if the hw vlan tag insertion feature is
activated then vlan tag 0 is inserted for non-vlan frames. VLAN-aware
hosts can deal with this, however this may pose problems for the
vlan-unaware ones (e.g. 802.1Q support not activated). I think this
is the main reason why the tx vlan accel is turned off by default.

regards,
Claudiu
