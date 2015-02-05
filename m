From: "Skidmore, Donald C" <donald.c.skidmore@intel.com>
Subject: RE: [net-next 03/16] ixgbe: cleanup sparse errors in new
 ixgbe_x550.c file
Date: Thu, 5 Feb 2015 23:19:02 +0000
Message-ID: <F6FB0E698C9B3143BDF729DF222866469129F556@ORSMSX110.amr.corp.intel.com>
References: <1423128950-12388-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1423128950-12388-4-git-send-email-jeffrey.t.kirsher@intel.com>
	<063D6719AE5E284EB5DD2968C1650D6D1CADC3FA@AcuExch.aculab.com>
 <20150205.144007.1425782923410995381.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>
To: David Miller <davem@davemloft.net>,
	"David.Laight@ACULAB.COM" <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:57169 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751091AbbBEXTF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 18:19:05 -0500
In-Reply-To: <20150205.144007.1425782923410995381.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, February 05, 2015 2:40 PM
> To: David.Laight@ACULAB.COM
> Cc: Kirsher, Jeffrey T; Skidmore, Donald C; netdev@vger.kernel.org;
> nhorman@redhat.com; sassmann@redhat.com; jogreene@redhat.com
> Subject: Re: [net-next 03/16] ixgbe: cleanup sparse errors in new
> ixgbe_x550.c file
> 
> From: David Laight <David.Laight@ACULAB.COM>
> Date: Thu, 5 Feb 2015 09:48:24 +0000
> 
> > From: Jeff Kirsher
> >> This patch cleans up prototypes that should have been defined as
> >> static.
> >>
> >> Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
> >> Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
> >> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >> ---
> >>  drivers/net/ethernet/intel/ixgbe/ixgbe_type.h |  4 +-
> >> drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c | 65
> >> ++++++++++++++-------------
> >>  2 files changed, 37 insertions(+), 32 deletions(-)
> >>
> >> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
> >> b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
> >> index d101b25..1f301ec 100644
> >> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
> >> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
> >> @@ -2451,8 +2451,8 @@ struct ixgbe_hic_read_shadow_ram {
> >>
> >>  struct ixgbe_hic_write_shadow_ram {
> >>  	union ixgbe_hic_hdr2 hdr;
> >> -	u32 address;
> >> -	u16 length;
> >> +	__be32 address;
> >> +	__be16 length;
> >>  	u16 pad2;
> >>  	u16 data;
> >>  	u16 pad3;
> >
> > Not related to commit message
> 
> Agreed, fix this up.

I'll get a cleaned up patch to Jeff.

Thanks,
-Don Skidmore <donald.c.skidmore@intel.com>
