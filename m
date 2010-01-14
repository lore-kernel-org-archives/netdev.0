From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next PATCH] igb: update adapter stats when reading
	/proc/net/dev.
Date: Wed, 13 Jan 2010 19:01:15 -0800
Message-ID: <9929d2391001131901l402a2b40t7c13205df99abd86@mail.gmail.com>
References: <20100112134153.27117.59960.stgit@firesoul.comx.local>
	 <20100113.173019.57466924.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hawk@comx.dk, alexander.h.duyck@intel.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f188.google.com ([209.85.222.188]:58479 "EHLO
	mail-pz0-f188.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751115Ab0ANDHo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2010 22:07:44 -0500
Received: by pzk26 with SMTP id 26so14360259pzk.4
        for <netdev@vger.kernel.org>; Wed, 13 Jan 2010 19:07:43 -0800 (PST)
In-Reply-To: <20100113.173019.57466924.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 13, 2010 at 17:30, David Miller <davem@davemloft.net> wrote=
:
> From: Jesper Dangaard Brouer <hawk@comx.dk>
> Date: Tue, 12 Jan 2010 14:41:53 +0100
>
>> Network driver igb: Improve the accuracy of stats in /proc/net/dev, =
by
>> updating the adapter stats when reading /proc/net/dev. =C2=A0Current=
ly the
>> stats are updated by the watchdog timer every 2 sec, or when getting
>> stats via ethtool -S.
>>
>> A number of userspace apps read these /proc/net/dev stats every seco=
nd,
>> e.g. ifstat, which then gives a perceived very bursty traffic patter=
n,
>> which is actually false.
>>
>> Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
>
> Intel folks, I assume you guys are going to integrate this.
>
> Thanks.
> --

Correct, I have sucked this into my queue of patches.

--=20
Cheers,
Jeff
