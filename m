From: Ethan Zhao <ethan.kernel@gmail.com>
Subject: Re: [PATCH 1/2 v2] ixgbe: define IXGBE_MAX_VFS_DRV_LIMIT macro and
 cleanup const 63
Date: Wed, 15 Jan 2014 21:05:46 +0800
Message-ID: <CABawtvPLZA+wLCvV5rPJ5wzQm5+M6UDaLMt-+pMUxwUjT+X4zg@mail.gmail.com>
References: <1387901568-1762-1-git-send-email-ethan.kernel@gmail.com>
	<1388134966.2183.144.camel@jtkirshe-mobl>
	<309B89C4C689E141A5FF6A0C5FB2118B7312CEE1@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Brown, Aaron F" <aaron.f.brown@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f173.google.com ([209.85.128.173]:48583 "EHLO
	mail-ve0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751747AbaAONFr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 08:05:47 -0500
In-Reply-To: <309B89C4C689E141A5FF6A0C5FB2118B7312CEE1@ORSMSX101.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Aaron,
   I will check the patch and make it pass the building, seems encoding issue.

Thanks,
Ethan

On Wed, Jan 15, 2014 at 11:46 AM, Brown, Aaron F
<aaron.f.brown@intel.com> wrote:
> On Fri, 2013-12-27 at 01:02 -0800, Jeff Kirsher wrote:
>> On Wed, 2013-12-25 at 00:12 +0800, Ethan Zhao wrote:
>> > Because ixgbe driver limit the max number of VF functions could be
>> > enabled
>> > to 63, so define one macro IXGBE_MAX_VFS_DRV_LIMIT and cleanup the
>> > const 63
>> > in code.
>> >
>> > v2: fix a typo.
>> >
>> > Signed-off-by: Ethan Zhao <ethan.kernel@gmail.com>
>> > ---
>> >  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  | 4 ++--
>> >  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 5 +++--
>> >  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h | 5 +++++
>> >  3 files changed, 10 insertions(+), 4 deletions(-)
>>
>> Added to my queue, thanks Ethan!
>
> Hi Ethan,
>
> Did Jeff contact you about this failing to compile?  I'm currently
> providing vacation covering for him and we found this was failing to
> compile just before he left.  We captured the failure in our notes for
> this but there is no comment on if you were contacted or not.
>
> Regardless, when I apply this patch (with or without 2-2) we get the
> following error on a compilation attempt: Here's the error:
> --------------------------------------------------------
> Here's the error:
> drivers/net/ethernet/intel/ixgbe/ixgbe_main.c: In function
> "ixgbe_sw_init":
> drivers/net/ethernet/intel/ixgbe/ixgbe_main.c:5033: error: stray "\357"
> in program
> drivers/net/ethernet/intel/ixgbe/ixgbe_main.c:5033: error: stray "\274"
> in program
> drivers/net/ethernet/intel/ixgbe/ixgbe_main.c:5033: error: stray "\215"
> in program
> drivers/net/ethernet/intel/ixgbe/ixgbe_main.c:5033: error: expected ")"
> before numeric constant
> drivers/net/ethernet/intel/ixgbe/ixgbe_main.c: In function
> "ixgbe_probe":
> drivers/net/ethernet/intel/ixgbe/ixgbe_main.c:7977: error: stray "\357"
> in program
> drivers/net/ethernet/intel/ixgbe/ixgbe_main.c:7977: error: stray "\274"
> in program
> drivers/net/ethernet/intel/ixgbe/ixgbe_main.c:7977: error: stray "\215"
> in program
> drivers/net/ethernet/intel/ixgbe/ixgbe_main.c:7977: error: expected ")"
> before numeric constant
> make[5]: *** [drivers/net/ethernet/intel/ixgbe/ixgbe_main.o] Error 1
> make[5]: *** Waiting for unfinished jobs....
> make[4]: *** [drivers/net/ethernet/intel/ixgbe] Error 2
> make[4]: *** Waiting for unfinished jobs....
> make[3]: *** [drivers/net/ethernet/intel] Error 2
> make[2]: *** [drivers/net/ethernet] Error 2
> make[1]: *** [drivers/net] Error 2
> make: *** [drivers] Error 2
> --------------------------------------------------------
>
> Thanks,
> Aaron
>
