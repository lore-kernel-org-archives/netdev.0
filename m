From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] igb: Fix unused variable warning.
Date: Wed, 27 Oct 2010 19:44:15 -0700 (PDT)
Message-ID: <20101027.194415.226784039.davem@davemloft.net>
References: <1288140963-20537-1-git-send-email-jesse@nicira.com>
	<AANLkTi=iDMYjMsvbeR9-ZhCE5zMHacO-vM5wTXvx4S9K@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jesse@nicira.com, netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38171
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932744Ab0J1Cnw convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Oct 2010 22:43:52 -0400
In-Reply-To: <AANLkTi=iDMYjMsvbeR9-ZhCE5zMHacO-vM5wTXvx4S9K@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 27 Oct 2010 19:13:23 -0700

> On Tue, Oct 26, 2010 at 17:56, Jesse Gross <jesse@nicira.com> wrote:
>> Commit eab6d18d "vlan: Don't check for vlan group before
>> vlan_tx_tag_present" removed the need for the adapter variable
>> in igb_xmit_frame_ring_adv(). =A0This removes the variable as well
>> to avoid the compiler warning.
>>
>> Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
>> Signed-off-by: Jesse Gross <jesse@nicira.com>
>> ---
>> =A0drivers/net/igb/igb_main.c | =A0 =A01 -
>> =A01 files changed, 0 insertions(+), 1 deletions(-)
>>
>=20
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
