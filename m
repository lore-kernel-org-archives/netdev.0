From: Greg Ungerer <gerg@snapgear.com>
Subject: Re: [PATCH v2 0/2] net: support for NS8390 based ethernet on ColdFire
 CPU boards
Date: Fri, 13 Jul 2012 11:05:34 +1000
Message-ID: <4FFF745E.8010202@snapgear.com>
References: <1341445800-396-1-git-send-email-gerg@snapgear.com> <20120712.075531.836132484757271226.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-m68k@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <20120712.075531.836132484757271226.davem@davemloft.net>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

On 13/07/12 00:55, David Miller wrote:
> From: <gerg@snapgear.com>
> Date: Thu, 5 Jul 2012 09:49:58 +1000
>
>>
>> This is version 2 of patches that add platform support for using the NS8390
>> based ethernet ports used on some ColdFire CPU boards. This version
>> incorporates only minor changes from the first.
>>
>> Patches to use these NS8390 devices on ColdFire boards have existed
>> out-of-tree for years. Some of the base IO definitions (those in
>> arch/m68k/include/asm/mcfne.h) have been in mainline, but unused for most
>> of that time.
>>
>> The first patch just neatens up mcfne.h (moving it to mcf8390.h). The
>> second patch is the platform driver. The first patch would normaly just
>> go through the m68knommu git tree, but I figured keeping these together made
>> more sense.
>
> Applied, thanks.

Great, thanks.


> Can you explain why we've had this completely unused header
> file mcfne.h in the tree?  Was it used by some external driver
> sources that were never merged?

That mcfne.h came in with all the other non-mmu m68k headers back in
the 2.5 kernel days. It was used by some external patches that modified
the existing ne.c ethernet driver. But they were really hacks, and a
bit ugly at that.

It was a recently pointed out by Paul Bolle on the m68k list that this
file still was unused in mainline, and that prompted me to actually sort
out the 8390 support on these boards and get it done right.

Regards
Greg


------------------------------------------------------------------------
Greg Ungerer  --  Principal Engineer        EMAIL:     gerg@snapgear.com
SnapGear Group, McAfee                      PHONE:       +61 7 3435 2888
8 Gardner Close                             FAX:         +61 7 3217 5323
Milton, QLD, 4064, Australia                WEB: http://www.SnapGear.com
