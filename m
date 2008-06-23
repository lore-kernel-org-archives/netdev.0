From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: stuck tcp connections 2.6.26-rc7
Date: Sun, 22 Jun 2008 20:59:27 -0700
Message-ID: <20080622205927.301501e7.akpm@linux-foundation.org>
References: <dd18b0c30806221109t2ff73f9ai52f6716748648a79@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: "Justin Mattock" <justinmattock@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:49778 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752991AbYFWD73 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jun 2008 23:59:29 -0400
In-Reply-To: <dd18b0c30806221109t2ff73f9ai52f6716748648a79@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 22 Jun 2008 18:09:16 +0000 "Justin Mattock" <justinmattock@gmail.com> wrote:

> Hello; I too am experiencing internet connectivity problems, for  a
> while I thought
> It was due to low bandwidth(or being ddos attacked) but yesterday I
> noticed with watch netstat -ntu
> send-Q was stuck on a number; the connection would not go to TIME_WAIT
> resulting in music to pause, and t.v. to freeze.
> In my experiences running xmms streaming music is fine, no problems,
> but as soon as
> you watch something with flash player the stream start's getting
> really bad. In the past with older kernel's
> I usually can watch t.v.(with flash) and stream music at the same time
> without any trouble.
> lately I've been Running the kernel in No forced Preemption with a
> time frequency at 100. having the kernel set in this mode really shows
> the connection problems, but if I change the preemption to another,
> and bump up the timer frequency the poor internet connection is not as
> bad(or stuck tcp) but still prevalent. more pops in the music, and
> sudden internet loss for around five seconds, then goes back
> So from over here streaming music has no problems from what I can see,
> but as soon as I watch media, it becomes a mess.

(cc netdev)
