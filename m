From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] pch_gbe: Adding read memory barriers
Date: Wed, 9 May 2012 16:39:16 +0100
Message-ID: <1336577956.8274.364.camel@deadeye>
References: <4FA822C4.60809@gmail.com>
	 <AE90C24D6B3A694183C094C60CF0A2F602CD83CB@saturn3.aculab.com>
	 <1336569510.8274.360.camel@deadeye>
	 <CAL2JzuxirjAnmbcV+R=MJFAi1+ayrRnM6i0Dz5poqMuG7Cxwxg@mail.gmail.com>
	 <AE90C24D6B3A694183C094C60CF0A2F602CD848A@saturn3.aculab.com>
	 <CAL2JzuxawnesC+=Fqyu71Hkwi5gnRughe_NYM4k1c=zqDoNGRg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@aculab.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <tshimizu818@gmail.com>
To: Erwan Velu <erwanaliasr1@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAL2JzuxawnesC+=Fqyu71Hkwi5gnRughe_NYM4k1c=zqDoNGRg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-05-09 at 17:20 +0200, Erwan Velu wrote:
> Thanks for this very clear description.

It might be clear, but it's not very relevant: you need to understand
the Linux kernel barrier APIs (which cover all architectures).  See
Documentation/memory-barriers.txt.

> As I'm pretty new to this kind of integration in the kernel, do you
> request me to test this volatile option ?
> Does the patch tends to be rejected for this issue ?
> What should be the next step for my patch ?
[...]

Explain what kind of reordering you are trying to avoid.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
