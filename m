From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next-2.6 PATCH 1/5] ixgbe: fix link down initial state
Date: Mon, 20 Apr 2009 02:15:04 -0700
Message-ID: <9929d2390904200215q37e04394w4d8878cc1af9a6b@mail.gmail.com>
References: <20090418064427.4328.45811.stgit@localhost.localdomain>
	 <20090420.020459.262772235.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	jesse.brandeburg@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.248]:64333 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751460AbZDTJPF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2009 05:15:05 -0400
Received: by an-out-0708.google.com with SMTP id d40so788648and.1
        for <netdev@vger.kernel.org>; Mon, 20 Apr 2009 02:15:04 -0700 (PDT)
In-Reply-To: <20090420.020459.262772235.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 20, 2009 at 2:04 AM, David Miller <davem@davemloft.net> wro=
te:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Fri, 17 Apr 2009 23:44:27 -0700
>
>> All the intel wired ethernet drivers were calling netif_carrier_off
>> and netif_stop_queue (or variants) before calling register_netdevice
>>
>> This is incorrect behavior as was pointed out by davem, and causes
>> ifconfig and friends to report a strange state before first link
>> after the driver was loaded, since without a netif_carrier_off, the =
stack
>> assumes carrier_on, but before register_netdev, netlink messages are=
 not
>> sent out telling link state.
>
> All 5 patches applied, thanks!
>
> FWIW, this is definitely a case where I would have found it just as
> appropriate to post one single patch for this. =C2=A0But that's just =
me :-)
> --

Good to know, that was discussed, but we thought it would be better
for git logging to have separate patches.

--=20
Cheers,
Jeff
