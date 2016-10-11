From: Aaron Conole <aconole@bytheb.org>
Subject: Re: slab corruption with current -git
Date: Tue, 11 Oct 2016 09:55:15 -0400
Message-ID: <f7tk2dff0sc.fsf@redhat.com>
References: <CA+55aFzntXuUyL85A68ghS-D-t3VdgKo9-FiqQBG3efW2xns3A@mail.gmail.com>
        <CA+55aFwS1jfnNzU=8CzRyxC79qKrStwmTXYrBHQYcftAg4LT3Q@mail.gmail.com>
        <20161009.235745.860945462339053703.davem@davemloft.net>
        <20161010.042401.637964142015887598.davem@davemloft.net>
        <20161011131709.GB24682@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
        fw@strlen.de, viro@zeniv.linux.org.uk, akpm@linux-foundation.org,
        axboe@fb.com, tytso@mit.edu, cl@linux.com, pablo@netfilter.org,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161011131709.GB24682@unicorn.suse.cz> (Michal Kubecek's
        message of "Tue, 11 Oct 2016 15:17:09 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michal Kubecek <mkubecek@suse.cz> writes:

> On Mon, Oct 10, 2016 at 04:24:01AM -0400, David Miller wrote:
>> From: David Miller <davem@davemloft.net>
>> Date: Sun, 09 Oct 2016 23:57:45 -0400 (EDT)
>> 
>> This means that the netns is possibly getting freed up before we
>> unregister the netfilter hooks.
>
> Sounds a bit like the issue discussed here:
>
>   https://marc.info/?l=netfilter-devel&m=146980917627262&w=2
>
> Could it be (partly) the same race condition?

It looks like it's possible.  It appears that there could be a
long-standing race between these.  I'll look into it more carefully, and
discuss with Pablo and Florian when they're situated from netdev
conference.

-Aaron
