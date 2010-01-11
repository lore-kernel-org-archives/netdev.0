From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 0/3] e1000e,igb,ixgbe: add registers etc. printout code
	just before resetting adapters
Date: Mon, 11 Jan 2010 13:52:12 -0800
Message-ID: <9929d2391001111352i7280dd76hca1089d9863d2f16@mail.gmail.com>
References: <4B45BBA5.8010407@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Bruce Allan <bruce.w.allan@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	Koki Sanagi <sanagi.koki@jp.fujitsu.com>,
	Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
To: Taku Izumi <izumi.taku@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:53566 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750809Ab0AKVwN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2010 16:52:13 -0500
Received: by pwj9 with SMTP id 9so1659787pwj.21
        for <netdev@vger.kernel.org>; Mon, 11 Jan 2010 13:52:12 -0800 (PST)
In-Reply-To: <4B45BBA5.8010407@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2010/1/7 Taku Izumi <izumi.taku@jp.fujitsu.com>:
>
> This patchset adds registers etc. printout code just before resetting=
 adapters
> to e1000e, igb, ixgbe modules. The registers, tx/rx rings status, des=
criptors,
> and buffer info will be helpful for detecting the root cause of adapt=
ers reset.
>
> This patchset is based on the following Jesse's debug patch of e1000e=
 module.
> =C2=A0http://marc.info/?l=3Dlinux-netdev&m=3D121446492912285&w=3D2
> I think that code is very useful, and should be comitted to upstream.
>
> The main difference between Jesse's patch and mine is as follows:
> =C2=A0- the function which invokes xxx_dump function. (xxx_clean_tx_i=
rq -> xxx_reset_task)
> =C2=A0- add the "dump_flag" module option to select category of print=
out
>
> The default output is netdevice status (transstart, last_rx), registe=
rs,
> and tx/rx rings' simple information. TX/RX descriptors information an=
d
> buffer_info =C2=A0can be output by changing the dump_flag module opti=
on, but,
> of course, the amount of output becomes quite large.
>
> =C2=A0*[PATCH 1/3] e1000e: add registers etc. printout code just befo=
re resetting adapters
> =C2=A0*[PATCH 2/3] igb: add registers etc. printout code just before =
resetting adapters
> =C2=A0*[PATCH 3/3] ixgbe: add registers etc. printout code just befor=
e resetting adapters
>
> Best regards,
> Taku Izumi <izumi.taku@jp.fujitsu.com>
>

Thanks Taku!  I have added your patches to my queue of patches.  Let
me know you are working on an updated version of these patches based
on Laurent Chavey's comments so that I can suck in your updated
versions of the patches when they become available.

--=20
Cheers,
Jeff
