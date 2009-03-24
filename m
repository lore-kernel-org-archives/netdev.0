From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] e1000: fix loss of multicast packets
Date: Tue, 24 Mar 2009 15:50:06 -0700
Message-ID: <9929d2390903241550j35ac4a3cp75a798802a62c26d@mail.gmail.com>
References: <20090320204415.25109.57486.stgit@lindenhurst-2.jf.intel.com>
	 <91bdcedb0903221105yafce0f4w1733a703c397bb7b@mail.gmail.com>
	 <20090323.010957.163908188.davem@davemloft.net>
	 <9929d2390903231953v463a3426jb6b698b0e9a4f51f@mail.gmail.com>
	 <91bdcedb0903240426y47e200fajfecbb7088e75427@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, jesse.brandeburg@intel.com,
	netdev@vger.kernel.org
To: Dave Boutcher <daveboutcher@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:50915 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754720AbZCXWuJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 18:50:09 -0400
Received: by yx-out-2324.google.com with SMTP id 31so2780722yxl.1
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2009 15:50:06 -0700 (PDT)
In-Reply-To: <91bdcedb0903240426y47e200fajfecbb7088e75427@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 24, 2009 at 4:26 AM, Dave Boutcher <daveboutcher@gmail.com>=
 wrote:
> On Mon, Mar 23, 2009 at 9:53 PM, Jeff Kirsher
> <jeffrey.t.kirsher@intel.com> wrote:
>> On Mon, Mar 23, 2009 at 1:09 AM, David Miller <davem@davemloft.net> =
wrote:
>>> From: Dave Boutcher <daveboutcher@gmail.com>
>>> Date: Sun, 22 Mar 2009 13:05:19 -0500
>>>
>>>> On Fri, Mar 20, 2009 at 3:44 PM, Jesse Brandeburg
>>>> <jesse.brandeburg@intel.com> wrote:
>>>> > From: Jesse Brandeburg <jesse.brandeburg@intel.com>
>>>> > This driver fix prepares an array all at once in memory and prog=
rams it in
>>>> > one shot to the hardware, not requiring an "erase" cycle.
>>>> >
>>>> > Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
>>>> > CC: Dave Boutcher <daveboutcher@gmail.com>
>>>>
>>>> Jesse, I just with this patch in my e1000 environment and it works
>>>> great. =C2=A0Almost 1,000,000 packets exchanged with active
>>>> membership join/drops going on and no packets lost. =C2=A0Thanks
>>>> for the fast turnaround.
>>>
>>> Thanks for testing Dave.
>>>
>>> Intel folks, can we get this formally submitted soon?
>>>
>>> Thanks.
>>> --
>>
>> Yes, I have it in my queue. =C2=A0It should be in the next series of=
 fixes
>> I will be sending out.
>
> At the risk of seeming demanding, an e1000e version as well? =C2=A0Th=
at's
> actually where the problem first showed up.
>
> Thanks,
>
> --
> Dave B
> --

We also have a patch for e1000e as well. :)

--=20
Cheers,
Jeff
