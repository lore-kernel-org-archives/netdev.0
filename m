From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [stable] ixgbe: Fix return of invalid txq
Date: Sun, 9 May 2010 22:13:40 -0700
Message-ID: <z2z9929d2391005092213pa4bf9a5fx4c028167749a5497@mail.gmail.com>
References: <alpine.WNT.2.00.1005031333200.4376@jbrandeb-desk1.amr.corp.intel.com>
	 <20100507222559.GE26579@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	stable@kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, brandon@ifup.org,
	David Miller <davem@davemloft.net>
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f171.google.com ([209.85.210.171]:49272 "EHLO
	mail-yx0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751126Ab0EJFNn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 01:13:43 -0400
In-Reply-To: <20100507222559.GE26579@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 7, 2010 at 15:25, Greg KH <greg@kroah.com> wrote:
> On Mon, May 03, 2010 at 01:56:57PM -0700, Brandeburg, Jesse wrote:
>> Please consider commit fdd3d631cddad20ad9d3e1eb7dbf26825a8a121f for
>> inclusion in 2.6.32.y (it is already in 2.6.33.y)
>>
>> Here is the commit message, it fixes a panic on machines with a larg=
er
>> number of cpus than ixgbe has tx queues (64).
>>
>> commit fdd3d631cddad20ad9d3e1eb7dbf26825a8a121f
>
> This doesn't apply at all on the .32-stable tree, as the logic has
> changed there. =C2=A0Care to properly backport it if you really need =
it
> there?
>
> thanks,
>
> greg k-h
> --

Sorry Greg, I will work on getting you a patch against your stable
tree before tomorrow night.

--=20
Cheers,
Jeff
