From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next-2.6] ixgbe: Use the instance of net_device_stats
	from net_device.
Date: Wed, 7 Oct 2009 17:45:59 -0700
Message-ID: <9929d2390910071745h5db007dbwad462e0469fa1a7a@mail.gmail.com>
References: <20091007124339.GA30083@serverengines.com>
	 <9929d2390910071634o42210a96s87e5703080d825b3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Ajit Khaparde <ajitk@serverengines.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f177.google.com ([209.85.222.177]:48690 "EHLO
	mail-pz0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753501AbZJHAqg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 20:46:36 -0400
Received: by pzk7 with SMTP id 7so545592pzk.33
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2009 17:45:59 -0700 (PDT)
In-Reply-To: <9929d2390910071634o42210a96s87e5703080d825b3@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 7, 2009 at 16:34, Jeff Kirsher <jeffrey.t.kirsher@intel.com=
> wrote:
> On Wed, Oct 7, 2009 at 05:43, Ajit Khaparde <ajitkhaparde@gmail.com> =
wrote:
>> Since net_device has an instance of net_device_stats,
>> we can remove the instance of this from the private adapter structur=
e.
>>
>> Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
>> ---
>> =C2=A0drivers/net/ixgbe/ixgbe.h =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0=
 =C2=A01 -
>> =C2=A0drivers/net/ixgbe/ixgbe_ethtool.c | =C2=A0 40 ++++++++++++++++=
+++-----------------
>> =C2=A0drivers/net/ixgbe/ixgbe_main.c =C2=A0 =C2=A0| =C2=A0 26 ++++++=
++++++------------
>> =C2=A03 files changed, 34 insertions(+), 33 deletions(-)
>>

Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
