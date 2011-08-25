From: Jeff Chua <jeff.chua.linux@gmail.com>
Subject: Re: pull request: wireless 2011-08-22
Date: Thu, 25 Aug 2011 11:33:05 +0800
Message-ID: <CAAJw_ZtFw5FxPy+boe_99mKQi7yt3yfGE6FqWrzmUD3T-y1v8w@mail.gmail.com>
References: <20110822190136.GJ2534@tuxdriver.com>
	<20110822.123326.1795268471389412471.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, IvDoorn@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110822.123326.1795268471389412471.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 23, 2011 at 3:33 AM, David Miller <davem@davemloft.net> wro=
te:
> From: "John W. Linville" <linville@tuxdriver.com>
> Date: Mon, 22 Aug 2011 15:01:37 -0400
>
>> This is a batch of fixes intended for 3.1. =A0Included is rewrite of=
 an
>> earlier iwlagn fix that was revealed to be flawed (bad pointer acces=
s
>> during module unload), a fix for a memory leak, and a trio of rt2x00
>> fixes with detailed changelogs. =A0These have all been in linux-next
>> for the last week with no reported complaints.
>>
>> Please let me know if there are problems!
>
> Pulled, thanks John.

I'm using the rt2800usb module for the Buffalo WLI-UC-GNM using ad-hoc =
mode.

T:  Bus=3D01 Lev=3D02 Prnt=3D02 Port=3D01 Cnt=3D01 Dev#=3D  3 Spd=3D480=
  MxCh=3D 0
D:  Ver=3D 2.00 Cls=3D00(>ifc ) Sub=3D00 Prot=3D00 MxPS=3D64 #Cfgs=3D  =
1
P:  Vendor=3D0411 ProdID=3D01a2 Rev=3D 1.01
S:  Manufacturer=3DRalink
S:  Product=3D802.11 n WLAN

It works ok, but after idling for a while, it does not response, and
module needs to unloaded and modprobe again to make it work.

The same mac80211 and cfg80211 works for iwlagn and no problem with
idling timeout.

Is there any parameter to control the rt2800usb to make turn off power =
saving?

I've tried "iwconfig lwan0 power timeout 0 power off" but no effect.

Linux 3.1.0-rc3 with commit caca9510ff4e5d842c0589110243d60927836222.

Thanks,
Jeff.
