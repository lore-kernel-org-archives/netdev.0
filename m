From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] e1000: fix loss of multicast packets
Date: Mon, 23 Mar 2009 19:53:54 -0700
Message-ID: <9929d2390903231953v463a3426jb6b698b0e9a4f51f@mail.gmail.com>
References: <20090320204415.25109.57486.stgit@lindenhurst-2.jf.intel.com>
	 <91bdcedb0903221105yafce0f4w1733a703c397bb7b@mail.gmail.com>
	 <20090323.010957.163908188.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: daveboutcher@gmail.com, jesse.brandeburg@intel.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:12642 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753744AbZCXCx4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 22:53:56 -0400
Received: by yx-out-2324.google.com with SMTP id 31so2399710yxl.1
        for <netdev@vger.kernel.org>; Mon, 23 Mar 2009 19:53:54 -0700 (PDT)
In-Reply-To: <20090323.010957.163908188.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 23, 2009 at 1:09 AM, David Miller <davem@davemloft.net> wro=
te:
> From: Dave Boutcher <daveboutcher@gmail.com>
> Date: Sun, 22 Mar 2009 13:05:19 -0500
>
>> On Fri, Mar 20, 2009 at 3:44 PM, Jesse Brandeburg
>> <jesse.brandeburg@intel.com> wrote:
>> > From: Jesse Brandeburg <jesse.brandeburg@intel.com>
>> > This driver fix prepares an array all at once in memory and progra=
ms it in
>> > one shot to the hardware, not requiring an "erase" cycle.
>> >
>> > Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
>> > CC: Dave Boutcher <daveboutcher@gmail.com>
>>
>> Jesse, I just with this patch in my e1000 environment and it works
>> great. =C2=A0Almost 1,000,000 packets exchanged with active
>> membership join/drops going on and no packets lost. =C2=A0Thanks
>> for the fast turnaround.
>
> Thanks for testing Dave.
>
> Intel folks, can we get this formally submitted soon?
>
> Thanks.
> --

Yes, I have it in my queue.  It should be in the next series of fixes
I will be sending out.

--=20
Cheers,
Jeff
