From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 0/4] net/sched: Use TC skip flags to reflect HW
 offload status
Date: Sun, 12 Feb 2017 11:54:25 +0200
Message-ID: <CAJ3xEMh=zOZX0yQEoi0T_zC+je2_ux=mSW0qG_sSr+2eyA_81A@mail.gmail.com>
References: <1486649888-2786-1-git-send-email-ogerlitz@mellanox.com> <20170210.143636.253114480501653886.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        John Fastabend <john.r.fastabend@intel.com>,
        Amir Vadai <amir@vadai.me>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>,
        Paul Blakey <paulb@mellanox.com>, Roi Dayan <roid@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:35242 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750915AbdBLJy1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Feb 2017 04:54:27 -0500
Received: by mail-oi0-f68.google.com with SMTP id x84so5181024oix.2
        for <netdev@vger.kernel.org>; Sun, 12 Feb 2017 01:54:26 -0800 (PST)
In-Reply-To: <20170210.143636.253114480501653886.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 10, 2017 at 9:36 PM, David Miller <davem@davemloft.net> wrote:
> From: Or Gerlitz <ogerlitz@mellanox.com>
> Date: Thu,  9 Feb 2017 16:18:04 +0200
>
>> Currently there is no way of querying whether a filter is
>> offloaded to HW or not when using both policy (no flag).
>>
>> Reuse the skip flags to show the insertion status by setting
>> the skip_hw flag in case the filter wasn't offloaded.
>>
>> The bpf patch is compile tested only, Daniel/Jakub, will
>> appreciate your review/ack.
>  ...
>
> I'm learning towards suggesting that you use new flags, this way it
> will be unambiguous whether we are running an old kernel.

> If you just use the skip flag, it's impossible to tell the difference.


Dave,

Re the old kernel argument, these patches are small and pointish,
would it make sense
to you to consider them as fixes and push them back to the relevant
stable kernels?

Or.
