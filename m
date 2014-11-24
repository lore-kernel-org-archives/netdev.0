From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: qstats update in packet scheduling
Date: Mon, 24 Nov 2014 10:42:48 -0800
Message-ID: <1416854568.17888.69.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAHmvzZQnBJbx3hfdvpXg0TZM-UooKxjM+-1HO6nSSpx4qJLcaw@mail.gmail.com>
	 <1416850289.17888.67.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHmvzZRwsd7S+T4cdAVzWGORcbkq+WWMtFAV6Ss3UrA+Ogeujg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Josh Clark <jcinma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:60314 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753523AbaKXSmv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2014 13:42:51 -0500
Received: by mail-ig0-f178.google.com with SMTP id hl2so3643907igb.11
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2014 10:42:51 -0800 (PST)
In-Reply-To: <CAHmvzZRwsd7S+T4cdAVzWGORcbkq+WWMtFAV6Ss3UrA+Ogeujg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-11-24 at 13:17 -0500, Josh Clark wrote:

> But I'm seeing no change at all in qlen. qlen and backlog are both
> zero, which results in zero qavg, meaning I can't test the RED
> functionality at all.

Wait. If you use some kernel patch without giving it, I can not comment.

If you use regular "tc -s qdisc ...", then you'll see non zero qlen
