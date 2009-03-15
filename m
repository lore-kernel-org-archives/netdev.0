From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-2.6 PATCH][RESEND] igb: remove ASPM L0s workaround
Date: Sat, 14 Mar 2009 18:39:18 -0700
Message-ID: <9929d2390903141839o7cf91c40u1fc308cc349f9231@mail.gmail.com>
References: <20090314063308.3837.66924.stgit@lost.foo-projects.org>
	 <20090314.125445.99853912.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.31]:40227 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755015AbZCOBjU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2009 21:39:20 -0400
Received: by yw-out-2324.google.com with SMTP id 5so634221ywh.1
        for <netdev@vger.kernel.org>; Sat, 14 Mar 2009 18:39:18 -0700 (PDT)
In-Reply-To: <20090314.125445.99853912.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 14, 2009 at 12:54 PM, David Miller <davem@davemloft.net> wr=
ote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Fri, 13 Mar 2009 23:35:34 -0700
>
>> From: Alexander Duyck <alexander.h.duyck@intel.com>
>>
>> The L0s workaround should be moved into a pci quirk and so it is not
>> necessary in the driver. =C2=A0This update removes the L0s workaroun=
d from the
>> igb driver.
>>
>> This was the second half of the PCI quirk patch with Matthew Wilcox =
did not
>> pick up when he picked up the quirk patch.
>>
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> Doesn't apply to net-2.6:
>
> davem@sunset:~/src/GIT/net-2.6$ apply "Alexander Duyck" "alexander.h.=
duyck@intel.com" diff msg
> error: patch failed: drivers/net/igb/igb_main.c:1126
> error: drivers/net/igb/igb_main.c: patch does not apply
> davem@sunset:~/src/GIT/net-2.6$
>
> And in fact if I try to apply it to net-next-2.6, that does
> work.
> --

My bad, I will re-spin the patch with your net-2.6 tree.

--=20
Cheers,
Jeff
