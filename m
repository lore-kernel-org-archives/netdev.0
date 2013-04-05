From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next 3/3] net/mlx4_en: Enable open-lldp DCB support
Date: Fri, 05 Apr 2013 00:52:38 -0700
Message-ID: <515E82C6.9080406@gmail.com>
References: <1365085574-12057-1-git-send-email-ogerlitz@mellanox.com> <1365085574-12057-4-git-send-email-ogerlitz@mellanox.com> <515DA342.5020503@intel.com> <515DA579.3050006@mellanox.com> <515DCDF2.8070304@intel.com> <CAJZOPZKms=25WUR5WL0DEZ7yAi=zOKjZEGdO1BQsyJ+tvPMe+g@mail.gmail.com> <515E129D.2020009@gmail.com> <CAJZOPZJgZNkABE4+40+CnmpDRHDzEY-ZZmTH3L5JyoMHJX0Cow@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
	Sagi Grimberg <sagig@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>, davem@davemloft.net,
	netdev@vger.kernel.org, amirv@mellanox.com
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:58142 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932563Ab3DEHyh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Apr 2013 03:54:37 -0400
Received: by mail-ob0-f170.google.com with SMTP id uy19so1266682obc.15
        for <netdev@vger.kernel.org>; Fri, 05 Apr 2013 00:54:37 -0700 (PDT)
In-Reply-To: <CAJZOPZJgZNkABE4+40+CnmpDRHDzEY-ZZmTH3L5JyoMHJX0Cow@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/05/2013 12:15 AM, Or Gerlitz wrote:
> John Fastabend <john.fastabend@gmail.com> wrote:
>
>> Agree it doesn't work without this patch but we can fix it in user
>> space. This has the nice benefit of letting lldpad work with mlx4 on
>> older kernels. In general I think its easier to update user space then
>> the kernel for most users. I'll send you a lldpad patch in a few moments.
>
> So to be sure we're on the same page, what we should do is enhance
> mlx4_en_dcbnl_getdcbx() routine to also return DCB_CAP_DCBX_HOST and

Right I think this is a better approach in the long run.

> work with your user space patch? sounds nice, except for what happens
> if people run with older versions of lldpad..
>

Well it won't work. But on the flip side all your older drivers _will_
work with the new daemon. My working assumption is for most users its
easier to upgrade a user space pkg than a kernel. And the simpler we
can keep the kernel code the better. Oh and also if there is a bug in
user space we shouldn't fix it with kernel code.

> Or.
>

-- 
John Fastabend         Intel Corporation
