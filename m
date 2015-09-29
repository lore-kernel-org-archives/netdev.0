From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: 4.3-rc3 Regression: NFS access stall by commit 6ae459bdaaee
Date: Tue, 29 Sep 2015 10:32:14 -0700
Message-ID: <CALnjE+poe5Vfe42fA2Uh+9shhgt2Lpq86b5vxUo5Ecyf8faiPQ@mail.gmail.com>
References: <s5ha8s6bscn.wl-tiwai@suse.de>
	<CALnjE+rpcayxdyXwkDAqJeBgJUTOGACoGEKZRq=GhE+RDuF0OQ@mail.gmail.com>
	<s5hk2r9zfab.wl-tiwai@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Trond Myklebust <trond.myklebust@primarydata.com>,
	Anupam Chanda <achanda@vmware.com>,
	Tom Herbert <tom@herbertland.com>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Takashi Iwai <tiwai@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:33556 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935218AbbI2RcP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 13:32:15 -0400
Received: by igbkq10 with SMTP id kq10so85732411igb.0
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 10:32:15 -0700 (PDT)
In-Reply-To: <s5hk2r9zfab.wl-tiwai@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 29, 2015 at 3:33 AM, Takashi Iwai <tiwai@suse.de> wrote:
> On Tue, 29 Sep 2015 02:35:04 +0200,
> Pravin Shelar wrote:
>>
>> On Mon, Sep 28, 2015 at 6:12 AM, Takashi Iwai <tiwai@suse.de> wrote:
>> > [I resent this since the previous mail didn't go out properly, as it
>> >  seems; apologies if you already read it, please disregard]
>> >
>> > Hi,
>> >
>> > I noticed that NFS access from my workstation slowed down drastically,
>> > almost stalls, with the fresh 4.3-rc3.  There are no particular kernel
>> > errors / warnings.
>> >
>> > Then I performed git section, and it leaded to the commit:
>> > 6ae459bdaaeebc632b16e54dcbabb490c6931d61
>> >     skbuff: Fix skb checksum flag on skb pull
>> >
>> > Reverting this commit from 4.3-rc3 fixed the issue indeed.
>> >
>> > Could you take a look at this?  I added Trond to Cc in case he might
>> > already know of it.
>> >
>> I send out fix for similar issue. Can you try the posted patch.
>> https://patchwork.ozlabs.org/patch/523632/
>
> Yes, the patch fixes the problem, thanks.  Feel free to take my
> tested-by tag:
>   Tested-by: Takashi Iwai <tiwai@suse.de>
>
Thanks for testing the patch.

> But I guess the real fix is only the first chunk and the latter is
> nothing but a cleanup?  If so, it'd be better to split it.
>

Both chunks are required for the fix.
