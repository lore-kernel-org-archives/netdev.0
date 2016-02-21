From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next] net_sched: add network namespace support for tc actions
Date: Sat, 20 Feb 2016 16:46:04 -0800
Message-ID: <CAM_iQpWzVoy7eYdf2Yxz2qfoAO5-pDZioACyu7Hws6u7vvP1Yw@mail.gmail.com>
References: <1455928994-9726-1-git-send-email-xiyou.wangcong@gmail.com>
	<56C8B21E.7070307@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f178.google.com ([209.85.160.178]:36479 "EHLO
	mail-yk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751179AbcBUAqG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Feb 2016 19:46:06 -0500
Received: by mail-yk0-f178.google.com with SMTP id z7so48954090yka.3
        for <netdev@vger.kernel.org>; Sat, 20 Feb 2016 16:46:05 -0800 (PST)
In-Reply-To: <56C8B21E.7070307@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 20, 2016 at 10:36 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
>
> Do you see a way to reduce the code duplication needed across all
> the action modules? I.e. that each of them now needs to register
> a new per netns subsystem, etc. In other words, is there a way the
> action API could be reworked to handle most of this in the tc core
> framework instead?

I definitely agree.

Initially I made a wrapper macro for the per netns API for each tc
action, but it didn't work as I thought, mostly due to the per net ops and
net_id stuffs.

So it is not as easy as it appears, it needs more work. At least the
current code is more readable than using any macro. We can always
refactor the API in the future, and as I mentioned in the changelog that
is in my plan.

Or do you have any quick and easy way to reduce the code?

Thanks.
