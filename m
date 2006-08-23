From: "Albert Cahalan" <acahalan@gmail.com>
Subject: Re: [take12 0/3] kevent: Generic event handling mechanism.
Date: Wed, 23 Aug 2006 00:35:26 -0400
Message-ID: <787b0d920608222135g4751ad8v567bf8098e0fb170@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.232]:44372 "EHLO
	wx-out-0506.google.com") by vger.kernel.org with ESMTP
	id S1751274AbWHWEf1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 00:35:27 -0400
Received: by wx-out-0506.google.com with SMTP id s14so2108902wxc
        for <netdev@vger.kernel.org>; Tue, 22 Aug 2006 21:35:27 -0700 (PDT)
To: drepper@redhat.com, nmiell@comcast.net, davem@davemloft.net,
	jmorris@namei.org, johnpol@2ka.mipt.ru,
	linux-kernel@vger.kernel.org, akpm@osdl.org,
	netdev@vger.kernel.org, zach.brown@oracle.com, hch@infradead.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ulrich Drepper writes:

> I so far also haven't taken the time to look exactly at the
> interface. I plan to do it asap since this is IMO our big chance
> to get it right. I want to have a unifying interface which can
> handle all the different events we need and which come up today
> and tomorrow.  We have to be able to handle not only file
> descriptors and AIO but also timers, signals, message queues
> (OK, they are file descriptors but let's make it official),
> futexes.  I'm probably missing the one or the other thing now.

Yeah, you're missing one. I must warn you, it's tasteless.
You forgot ptrace events. (everybody now: EEEEEEEW!)

The wait-related functions in general are interesting.
People like to use a general event mechanism to deal with
threads exiting. Seriously, it would really help with
porting code from that other OS.

How about SysV semaphores?
