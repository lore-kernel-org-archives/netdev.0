From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next PATCH] e1000e: allow tx of pre-formatted vlan tagged
	packets
Date: Wed, 18 Mar 2009 23:55:31 -0700
Message-ID: <9929d2390903182355s458a9675mdbbe65e3d548eddd@mail.gmail.com>
References: <20090317195905.GA22551@ajones-laptop.nbttech.com>
	 <20090318.234102.202869351.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ajones@riverbed.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, shemminger@vyatta.com,
	alexander.h.duyck@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:40727 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754246AbZCSGzd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 02:55:33 -0400
Received: by yx-out-2324.google.com with SMTP id 31so416171yxl.1
        for <netdev@vger.kernel.org>; Wed, 18 Mar 2009 23:55:31 -0700 (PDT)
In-Reply-To: <20090318.234102.202869351.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 18, 2009 at 11:41 PM, David Miller <davem@davemloft.net> wr=
ote:
> From: Arthur Jones <ajones@riverbed.com>
> Date: Tue, 17 Mar 2009 12:59:05 -0700
>
>> As with igb, when the e1000e driver is fed 802.1q
>> packets with hardware checksum on, it chokes with an
>> error of the form:
>>
>> checksum_partial proto=3D81!
>>
>> As the logic there was not smart enough to look into
>> the vlan header to pick out the encapsulated protocol.
>>
>> There are times when we'd like to send these packets
>> out without having to configure a vlan on the interface.
>> Here we check for the vlan tag and allow the packet to
>> go out with the correct hardware checksum.
>>
>> Thanks to Kand Ly <kand@riverbed.com> for discovering the
>> issue and the coming up with a solution. =C2=A0This patch is
>> based upon his work.
>>
>> Fixups from Stephen Hemminger <shemminger@vyatta.com> and
>> Alexander Duyck <alexander.h.duyck@intel.com>.
>>
>> Signed-off-by: Arthur Jones <ajones@riverbed.com>
>
> Jeff K., you got this one too?
> --

Yes.  I have both.  The are both in my queue, and I should have
something for you Dave later tonight/tomorrow morning.

--=20
Cheers,
Jeff
