From: Jiri Benc <jbenc@suse.cz>
Subject: Re: Broadcom 43xx first results
Date: Mon, 5 Dec 2005 21:42:56 +0100
Message-ID: <20051205214256.492421ad@griffin.suse.cz>
References: <E1Eiyw4-0003Ab-FW@www1.emo.freenet-rz.de>
	<20051205190038.04b7b7c1@griffin.suse.cz>
	<200512052123.42357.mbuesch@freenet.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, bcm43xx-dev@lists.berlios.de,
	NetDev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751459AbVLEUm7@vger.kernel.org>
To: Michael Buesch <mbuesch@freenet.de>
In-Reply-To: <200512052123.42357.mbuesch@freenet.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 5 Dec 2005 21:23:42 +0100, Michael Buesch wrote:
> This is __not__ "yet another stack". It is an _extension_.
> It is all about management frames, which the in-kernel code
> does not manage.

But this code should be part of the stack, as nearly every driver needs
it. Management handling should be really managed by the kernel. The same
applies to driver<->userspace communication - there is no need to bother
every driver with it. And so on.

The hard part is that every driver will need a slightly different amount
of this support depending on the amount of features that are provided by
firmware.

> We want a working device. The driver is in a state where it
> is more or less usable. What is missing, is code to handle
> management.

I understand.

> We tried the code from the RTL driver, but it is total crap.
> We dropped it again. We thought about using yet another out of
> kernel ieee80211 stack, but we began to write an extension
> to the in-kernel code. If that was right or wrong, well, that's
> the question.
> 
> If you _really_ think we should have used $EXTERNAL_STACK,
> go and patch the driver to work with it.

No. I just think we (everybody) should concentrate at one particular
stack, finish it and merge it. And I'm convinced Jouni's stack is
currently the best solution available - far far from perfect, with many
issues, but still the best - and it will finally save as much time.


-- 
Jiri Benc
SUSE Labs
