From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Potential out-of-bounds access in ip6_finish_output2
Date: Wed, 18 Sep 2013 00:48:51 +0200
Message-ID: <20130917224851.GB8947@order.stressinduktion.org>
References: <CACT4Y+ZXqoixvCyN5703+sVhCV4ND-vNwash2Z1vSDoLgKNyVg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	Paul Turner <pjt@google.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Tom Herbert <therbert@google.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:35123 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752003Ab3IQWsw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Sep 2013 18:48:52 -0400
Content-Disposition: inline
In-Reply-To: <CACT4Y+ZXqoixvCyN5703+sVhCV4ND-vNwash2Z1vSDoLgKNyVg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 16, 2013 at 10:13:10PM -0700, Dmitry Vyukov wrote:
> Hi,
> 
> I am working on AddressSanitizer -- a tool that detects use-after-free
> and out-of-bounds bugs
> (https://code.google.com/p/address-sanitizer/wiki/AddressSanitizerForKernel).
> 
> I've got a dozen of reports in ip6_finish_output2. Below are 2 of
> them. They are always followed by kernel crash. Unfortunately I don't
> have a reproducer because I am using trinity fuzzer. I would
> appreciate if somebody familiar with the code look at sources and
> maybe spot the bug.

Thanks for the report!

I tried reproducing the bug and hit some other bugs nearby. I'll try to fix
them, but this could take some time.

Greetings,

  Hannes
