From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net-next 2/2] bonding: remove alb_set_mac_address()
Date: Fri, 23 May 2014 09:38:42 +0300
Message-ID: <CAJZOPZJHr0fpAaUM_X0Bwa1PtTO0ra3KLu5AFdir2ShKGFrukA@mail.gmail.com>
References: <1400764324-23221-1-git-send-email-vfalico@gmail.com>
	<1400764324-23221-3-git-send-email-vfalico@gmail.com>
	<CAJZOPZKHm_0zpHQWSVrkcs4YsRbYSTWj1DU7SMG6PHHCeZcb3Q@mail.gmail.com>
	<20140522145724.GA1995@mikrodark.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Eyal Perry <eyalpe@mellanox.com>
To: Veaceslav Falico <vfalico@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f177.google.com ([209.85.216.177]:58023 "EHLO
	mail-qc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752490AbaEWGim (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2014 02:38:42 -0400
Received: by mail-qc0-f177.google.com with SMTP id i17so7250465qcy.8
        for <netdev@vger.kernel.org>; Thu, 22 May 2014 23:38:42 -0700 (PDT)
In-Reply-To: <20140522145724.GA1995@mikrodark.usersys.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 22, 2014 at 5:57 PM, Veaceslav Falico <vfalico@gmail.com> wrote:
>
> On Thu, May 22, 2014 at 05:36:19PM +0300, Or Gerlitz wrote:
>>
>>
>> So with this patch @ hand, no more touching of the underlying device
>> dev_addr field directly -- or we still have more accesses of this
>> such, e.g in  bond_alb_set_mac_address() and/or friends?
>
>
> Sorry, but no :(. I'm still working on it, and already sent several
> patchsets approaching it :).
>
> Hopefully it will be ready next week. If you need it urgently - patches welcome :)



Hey -- no rush, I just asked as heads up since we have some proposed
mlx4 driver change which was done also under the assumption that
bonding touches directly the underlying dev_addr directly and I wanted
to see where this stands, so we can re-evaluate the driver patch

Or.
