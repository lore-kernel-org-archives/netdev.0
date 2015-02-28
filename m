From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] netns: avoid allocating idr when dumping info
Date: Fri, 27 Feb 2015 16:48:20 -0800
Message-ID: <CAM_iQpUx69wuHyTY-L6eAhNzuCWxhVd-jSHcKXq7cW4NXBZpOQ@mail.gmail.com>
References: <1425018776-14725-1-git-send-email-xiyou.wangcong@gmail.com>
	<1425024069.5130.10.camel@edumazet-glaptop2.roam.corp.google.com>
	<54F09A95.8000507@6wind.com>
	<CAM_iQpUPQVodJRGmf=GYOVK+R_84w-+yDtqyHCJGbCDH0hb44A@mail.gmail.com>
	<1425060255.5130.39.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:37972 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751105AbbB1AsV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 19:48:21 -0500
Received: by pdbfp1 with SMTP id fp1so24759010pdb.5
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 16:48:21 -0800 (PST)
In-Reply-To: <1425060255.5130.39.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 27, 2015 at 10:04 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2015-02-27 at 09:28 -0800, Cong Wang wrote:
>
>> I don't understand why you think this is over engineering,
>> clearly it is normal to allocate resources in newlink rather than
>> dumping. Look at other resources we allocate in newlink.
>
> This has nothing to do with the splat you gave.


Why not? If we from the beginning can avoid allocate any
memory in dumping, such rcu warning would not even trigger.

>
> If you believe there is a _different_ bug, then submit another patch.

I am not 100% sure it is a bug yet, but it does signal some bad sign.

>
> But claiming your patch solves the rcu thing is misleading,
> you gave already 2 wrong patches, trying to hide the real fix.
>

If rcu read lock were the only problem, I wouldn't even want to
reply, too trivial to worthy a reply.
