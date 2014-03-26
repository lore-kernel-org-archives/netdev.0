From: hayeswang <hayeswang@realtek.com>
Subject: RE: [PATCH net-next 12/12] r8152: modify the tx timeout funcfion
Date: Wed, 26 Mar 2014 17:54:11 +0800
Message-ID: <47E2CB72EA2845AD9B81A98B6E3BDF6B@realtek.com.tw>
References: <1393934464-23675-1-git-send-email-hayeswang@realtek.com><1393934464-23675-13-git-send-email-hayeswang@realtek.com> <CANEJEGvB7K3EQ6hyyweT3MA3kWSMcvAGXNHSTZK=6_z=dHhTfA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: 'netdev' <netdev@vger.kernel.org>, <nic_swsd@realtek.com>,
	'LKML' <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>
To: 'Grant Grundler' <grundler@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANEJEGvB7K3EQ6hyyweT3MA3kWSMcvAGXNHSTZK=6_z=dHhTfA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 Grant Grundler [mailto:grundler@google.com] 
> Sent: Wednesday, March 26, 2014 4:12 AM
[...]
> Hayes,
> I believe this patch was dropped after the series was split.
> Can you please repost this patch by itself?

There is no problem for current behavior, and I don't get the
issue of tx timeout, yet. I think the other patches are prior
to this one, so I plan to deal with this one after the others.
Besides, maybe I would have different idea for this one then.
Although reinitialization is more safe, I don't sure if it is
necessary.

> (and fix the "function" typo in the patch header)

oops.

[...]
> Nit: Could rtl_ops.up() set speed since it appears to be changing the
> state of the link?

I don't plan to do it. I don't think it is a part of rtl_ops.up().
Although it alwayes follows rtl_ops.up() now, I think they should
be separeted because they are for different purposes. The set_speed
is used to make sure the speed is correct, because you don't know
what speed it is before the driver is loaded. The other OS may
change the speed, so the device should have opportunity to change
the speed to the default when the driver is loaded. Normally, the
set_speed is not necessary.

> rtl8152_open() uses a remarkably similar code sequence. Is there an
> opportunity to refactor and  make sure this sequence is consistent?
> (different patch, not this one)

It is a good question. I would think about it.
 
Best Regards,
Hayes
