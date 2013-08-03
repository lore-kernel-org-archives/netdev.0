From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net] net: mlx5: fix sizeof usage in health_care's reg_handler
Date: Sun, 4 Aug 2013 00:42:52 +0300
Message-ID: <CAJZOPZ+2ELFBBPOnQdcLJVX4TVAsXvBUiGyupcRKahgATw1=-g@mail.gmail.com>
References: <1375438577-30933-1-git-send-email-dborkman@redhat.com>
	<20130802.151132.539136654627638979.davem@davemloft.net>
	<51FC3620.3020401@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: ogerlitz@mellanox.com, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Eli Cohen <eli@dev.mellanox.co.il>
To: Daniel Borkmann <dborkman@redhat.com>, Eli Cohen <eli@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:35961 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753127Ab3HCVmx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Aug 2013 17:42:53 -0400
Received: by mail-qa0-f46.google.com with SMTP id bq6so308782qab.5
        for <netdev@vger.kernel.org>; Sat, 03 Aug 2013 14:42:52 -0700 (PDT)
In-Reply-To: <51FC3620.3020401@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 3, 2013 at 1:43 AM, Daniel Borkmann <dborkman@redhat.com> wrote:

> On 08/03/2013 12:11 AM, David Miller wrote:
>>
>> From: Daniel Borkmann <dborkman@redhat.com>
>> Date: Fri,  2 Aug 2013 12:16:17 +0200
>>
>>> Therefore, I strongly assume sizeof(*health->health) is being meant
>>> to be passed as an argument. Interestingly, there are actually no
>>> in-tree users of mlx5_[un]register_health_report_handler(), but some
>>> debugging modules might want to know the correct size instead.
>>
>>
>> I want these hooks and infrastructure removed immediately.
>>
>> If there are no in-tree users there is no reason for them to
>> exist at all.
>
>
> Ok, I let Or handle that. Maybe he wants to add a user of it, instead.
>
> I also noticed that coverty scanner found a couple of other issues,
> e.g. outlen_write() in mlx5/core/cmd.c does a kzalloc() without
> doing sanity checks on the user-passed allocation size, e.g. it
> could even be a negative value passed to it.

Hi Daniel,

As listed in the kernel maintainers file, Eli Cohen (copied) is the
upstream maintainer for the mlx5 driver, please make sure to send/copy him
on patches/questions you have on mlx5. I will let Eli answer/handle your
findings/questions.

Or.
