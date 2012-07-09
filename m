From: Mark Lord <kernel@teksavvy.com>
Subject: Re: [PATCH 0/4] Add a driver for the ASIX AX88172A
Date: Mon, 09 Jul 2012 18:27:18 -0400
Message-ID: <4FFB5AC6.3000506@teksavvy.com>
References: <1341574388-7464-1-git-send-email-christian.riesch@omicron.at> <CANEJEGuiw7w0aV47AnRQGzqBNCyAb7jj9t+Dh2XbzwMtV=doWw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Christian Riesch <christian.riesch@omicron.at>,
	netdev@vger.kernel.org, Oliver Neukum <oneukum@suse.de>,
	Eric Dumazet <edumazet@google.com>,
	Allan Chou <allan@asix.com.tw>,
	Ming Lei <tom.leiming@gmail.com>,
	Michael Riesch <michael@riesch.at>
To: Grant Grundler <grundler@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ironport2-out.teksavvy.com ([206.248.154.182]:28530 "EHLO
	ironport2-out.teksavvy.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752246Ab2GIW1Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 18:27:24 -0400
In-Reply-To: <CANEJEGuiw7w0aV47AnRQGzqBNCyAb7jj9t+Dh2XbzwMtV=doWw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12-07-09 01:45 PM, Grant Grundler wrote:
> Christian,
> Here's my $0.02 response to your questions.
> 
> On Fri, Jul 6, 2012 at 4:33 AM, Christian Riesch
> <christian.riesch@omicron.at> wrote:
> ...
>> I have a few questions:
>>
>> 1) Is it ok to factor out the common code like I did? Or should
>>    it go into a separate kernel module?
> 
> I think it's ok. I'd rather not see additional kernel modules unless
> the driver is substantially different.

I'll second that.  Ideally, somebody should pick up the pieces
from my aborted efforts last fall, and just get the real ASIX driver
itself tidied and into the kernel.  Then *everything* would work.

But I doubt that would be feasible at this point.

Cheers
