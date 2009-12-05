From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 06/31] Constify struct e1000_mac_operations for 2.6.32 v1
Date: Fri, 4 Dec 2009 17:21:29 -0800
Message-ID: <9929d2390912041721g185d5f95s809a80811d2ac292@mail.gmail.com>
References: <4B198670.2000406@gmail.com> <4B198A33.7080705@gmail.com>
	 <4B19A337.6060808@gmail.com>
	 <20091205114048.37df384e.sfr@canb.auug.org.au>
	 <4B19B4FA.5080904@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	peter.p.waskiewicz.jr@intel.com, john.ronciak@intel.com,
	torvalds@linux-foundation.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, netdev@vger.kernel.org
To: Emese Revfy <re.emese@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:43777 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932656AbZLEBVX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2009 20:21:23 -0500
In-Reply-To: <4B19B4FA.5080904@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2009/12/4 Emese Revfy <re.emese@gmail.com>:
> Stephen Rothwell wrote:
>> Hi Emese,
>>
>> On Sat, 05 Dec 2009 01:03:03 +0100 Emese Revfy <re.emese@gmail.com> =
wrote:
>>> --- a/drivers/net/e1000e/82571.c
>>> +++ b/drivers/net/e1000e/82571.c
>>> @@ -212,6 +212,7 @@ static s32 e1000_init_mac_params_82571(struct e=
1000_adapter *adapter)
>>> =C2=A0{
>>> =C2=A0 =C2=A0 =C2=A0struct e1000_hw *hw =3D &adapter->hw;
>>> =C2=A0 =C2=A0 =C2=A0struct e1000_mac_info *mac =3D &hw->mac;
>>> + =C2=A0 =C2=A0/* cannot be const */
>>> =C2=A0 =C2=A0 =C2=A0struct e1000_mac_operations *func =3D &mac->ops=
;
>>
>> Adding to the comment to say why it can't be const may allow us to f=
ix
>> this later ...
>
> Ok, in the next patch series I will explain each case.
> --

Also, please sync up your patches with what is in Dave's net-next-2.6
tree, because some of the changes made no longer apply since the code
was either changed or removed.

--=20
Cheers,
Jeff
