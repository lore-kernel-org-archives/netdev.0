From: Veaceslav Falico <vfalico@gmail.com>
Subject: Re: [PATCH net-next 2/2] bonding: remove alb_set_mac_address()
Date: Thu, 22 May 2014 16:57:24 +0200
Message-ID: <20140522145724.GA1995@mikrodark.usersys.redhat.com>
References: <1400764324-23221-1-git-send-email-vfalico@gmail.com>
 <1400764324-23221-3-git-send-email-vfalico@gmail.com>
 <CAJZOPZKHm_0zpHQWSVrkcs4YsRbYSTWj1DU7SMG6PHHCeZcb3Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Eyal Perry <eyalpe@mellanox.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f178.google.com ([74.125.82.178]:54787 "EHLO
	mail-we0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750729AbaEVO5u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 10:57:50 -0400
Received: by mail-we0-f178.google.com with SMTP id u56so3511073wes.37
        for <netdev@vger.kernel.org>; Thu, 22 May 2014 07:57:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAJZOPZKHm_0zpHQWSVrkcs4YsRbYSTWj1DU7SMG6PHHCeZcb3Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 22, 2014 at 05:36:19PM +0300, Or Gerlitz wrote:
>On Thu, May 22, 2014 at 4:12 PM, Veaceslav Falico <vfalico@gmail.com> wrote:
>>
>> Currently it's called only from bond_alb_set_mac_address(), which is called
>> only for ALB mode, and it does nothing in case the mode is ALB. So,
>> basically, it's a no-op. All the needed functionality (modifying the active
>> slave's mac address, per example) is handled by the
>> bond_alb_set_mac_address() itself.
>
>So with this patch @ hand, no more touching of the underlying device
>dev_addr field directly -- or we still have more accesses of this
>such, e.g in  bond_alb_set_mac_address() and/or friends?

Sorry, but no :(. I'm still working on it, and already sent several
patchsets approaching it :).

Hopefully it will be ready next week. If you need it urgently - patches
welcome :).

>
>Or.
