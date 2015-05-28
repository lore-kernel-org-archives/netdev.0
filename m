From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Lost network connectivity in 4.0.x
Date: Wed, 27 May 2015 22:53:00 -0700
Message-ID: <CAM_iQpXH_-WO8W=zVUaXezeGGOjFy-nBLy0k+tytZuMQqV1hcQ@mail.gmail.com>
References: <20150524024352.GA15747@milliways>
	<20150524032938.GA16664@milliways>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: LKML <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Ken Moffat <zarniwhoop@ntlworld.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f171.google.com ([209.85.214.171]:33137 "EHLO
	mail-ob0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751238AbbE1FxB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 01:53:01 -0400
In-Reply-To: <20150524032938.GA16664@milliways>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Please always Cc netdev for networking bugs.)

On Sat, May 23, 2015 at 8:29 PM, Ken Moffat <zarniwhoop@ntlworld.com> wrote:
> On Sun, May 24, 2015 at 03:43:52AM +0100, Ken Moffat wrote:
>> Anybody else suffering frm lost network connectivity in 4.0.x
>> kernels ?  A couple of times this week, vim on an nfs-3 mount hung
>> and I had to reboot.  Both of those occasions were on an AMD desktop
>> with the r8169 driver, running 4.0.3.  I thought it might be
>> specific to that machine.  For the last two or three days I've been
>> using an intel, and about 10 minutes ago it suffered the same problem
>> while running 4.0.4.  Using ping from another term showed that it
>> had no connectivity to the server on my local network.
>>
>> This is a bit hard to diagnose - nothing in the logs.
>>
> I forgot to add that this is with the released gcc-5.1 : I keep
> forgetting that some people use old compilers ;-)
>

Is there any way you can help to narrow down the problem?

For example:

1) What is your network setup? iptables? routes? etc.

2) Can you check the stats to see if there is any error?
  `ip -s -s li show`, `ethtool -S <DEV>`

3) Do a bisect?

Thanks!
