From: Grant Grundler <grundler@google.com>
Subject: Re: [PATCH 1/1] Workaround for Suspend/Resume issue of AX88772B under ChromeOS
Date: Wed, 20 Nov 2013 11:32:50 -0800
Message-ID: <CANEJEGtXOjxj+85QVfWFGH6WuxxCz6uAfEuUo7bv9YEwh_8OAw@mail.gmail.com>
References: <1384913496-26261-1-git-send-email-freddy@asix.com.tw>
	<20131120.004026.2013972041095203460.davem@davemloft.net>
	<CANEJEGtBmvFNcFzOW9ZnOFd=ZMnz82ajcN52YqW3+n0+=rhxBA@mail.gmail.com>
	<20131120.135413.920731121262719289.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Freddy Xin <freddy@asix.com.tw>, netdev <netdev@vger.kernel.org>,
	linux-usb@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	davemloft@davemloft.net,
	=?UTF-8?B?QVNJWCBMb3VpcyBb6JiH5aiB6Zm4XQ==?= <louis@asix.com.tw>,
	Allan Chou <allan@asix.com.tw>,
	Daniel_ASIX <daniel@asix.com.tw>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131120.135413.920731121262719289.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 20, 2013 at 10:54 AM, David Miller <davem@davemloft.net> wrote:
> From: Grant Grundler <grundler@google.com>
> Date: Wed, 20 Nov 2013 09:42:42 -0800
>
>> While this patch raises a new issue, can you apply this patch anyway
>> since in most cases (default settings) it improves "the user
>> experience" for most users?
>
> I'm not applying a patch which knowingly is not implemented correctly.

Ok - fair enough. I'll figure out what needs to be done to
save/restore phy values.

Seems like this should be part of usbnet_resume code based on whether
the driver provides mdio_write hook (most USBNET drivers do).

thanks,
grant
