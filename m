From: Jon Mason <jdmason@kudzu.us>
Subject: Re: [trivial PATCH 2/7] ixgbe: remove unused #define
Date: Thu, 12 Jul 2012 12:49:43 -0700
Message-ID: <CAPoiz9wcj7tbgVUf+D=HdonXnaMYFHb+TmSb77f2R2mpwGQM7g@mail.gmail.com>
References: <1341959492-31389-1-git-send-email-jdmason@kudzu.us>
	<1341959492-31389-2-git-send-email-jdmason@kudzu.us>
	<1341960208.3336.43.camel@jtkirshe-mobl>
	<1342116938.1783.57.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: trivial@kernel.org, linux-kernel@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	netdev <netdev@vger.kernel.org>
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:51653 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030750Ab2GLTto (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 15:49:44 -0400
Received: by lbbgm6 with SMTP id gm6so4677760lbb.19
        for <netdev@vger.kernel.org>; Thu, 12 Jul 2012 12:49:43 -0700 (PDT)
In-Reply-To: <1342116938.1783.57.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 12, 2012 at 11:15 AM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> On Tue, 2012-07-10 at 15:43 -0700, Jeff Kirsher wrote:
>> On Tue, 2012-07-10 at 15:31 -0700, Jon Mason wrote:
>> > Remove unused IXGBE_INTEL_VENDOR_ID #define
>> >
>> > Signed-off-by: Jon Mason <jdmason@kudzu.us>
>> > Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> > Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
>> > Cc: Bruce Allan <bruce.w.allan@intel.com>
>> > Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>
>> > Cc: Don Skidmore <donald.c.skidmore@intel.com>
>> > Cc: Greg Rose <gregory.v.rose@intel.com>
>> > Cc: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
>> > Cc: Alex Duyck <alexander.h.duyck@intel.com>
>> > Cc: John Ronciak <john.ronciak@intel.com>
>> > ---
>> >  drivers/net/ethernet/intel/ixgbe/ixgbe_type.h |    3 ---
>> >  1 file changed, 3 deletions(-)
>>
>> This should also go through David Miller's networking tree's.  Adding
>> netdev mailing list.
>>
>> Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> After looking at this further, I rescind my ACK.
>
> NAK, this define is used in several places in ixgbe_main.c and the
> driver will not compile with this patch.

My apologies, I was a bit sloppy and simply rebased my old patches
without retesting them.  The code has changed since I originally
pushed the patch (http://www.spinics.net/lists/netdev/msg171523.html).
 I will fix and resubmit.

Thanks,
Jon


>>
>> >
>> > diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
>> > index 204848d..c8d8040 100644
>> > --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
>> > +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
>> > @@ -32,9 +32,6 @@
>> >  #include <linux/mdio.h>
>> >  #include <linux/netdevice.h>
>> >
>> > -/* Vendor ID */
>> > -#define IXGBE_INTEL_VENDOR_ID   0x8086
>> > -
>> >  /* Device IDs */
>> >  #define IXGBE_DEV_ID_82598               0x10B6
>> >  #define IXGBE_DEV_ID_82598_BX            0x1508
>>
>>
>
