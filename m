From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next 12/18] IB/mlx5: Add kernel offload flow-tag
Date: Sun, 19 Jun 2016 17:27:02 +0300
Message-ID: <CALzJLG-fQV47mThWiioQ=gkFOSvSGQ2ws9tzHMx5iUqy2TSJwA@mail.gmail.com>
References: <1466174639-14576-1-git-send-email-saeedm@mellanox.com>
 <1466174639-14576-13-git-send-email-saeedm@mellanox.com> <20160617160007.GA52082@ast-mbp.thefacebook.com>
 <CALzJLG-uoMKjZCC312JjfqnQaUW_-31eqeg0bQd+r3qp4Fa1ag@mail.gmail.com> <CANn89iLytk1fefd5kwUYHk8UXg_-LE_NOz6xxqMRSHRGkzDrZA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Doug Ledford <dledford@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Huy Nguyen <huyn@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f193.google.com ([209.85.161.193]:32839 "EHLO
	mail-yw0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750784AbcFSO1X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2016 10:27:23 -0400
Received: by mail-yw0-f193.google.com with SMTP id d137so7608797ywe.0
        for <netdev@vger.kernel.org>; Sun, 19 Jun 2016 07:27:22 -0700 (PDT)
In-Reply-To: <CANn89iLytk1fefd5kwUYHk8UXg_-LE_NOz6xxqMRSHRGkzDrZA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 18, 2016 at 2:34 AM, Eric Dumazet <edumazet@google.com> wrote:
> On Fri, Jun 17, 2016 at 3:31 PM, Saeed Mahameed
> <saeedm@dev.mellanox.co.il> wrote:
>>
>> Today there are some bad usages and abuse to skb->protocol where some
>> device drivers set skb->protocol = 0xffffff to skip the kernel TCP/IP
>> processing for the same diagnostic purposes.
>> In this series we are just trying to do the right thing.
>
> Well, your patch adds an extra test in kernel fast path, just to ease
> the life of people using kernel bypass,
> but willing to use tcpdump because they can not figure to do this in
> user space properly.
>
> Please find a way  _not_ adding a single instruction in kernel fast path.
>

Well, we can set skb->protocol = 0xffff.
what do you think ?
