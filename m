From: "Leonid Grossman" <leonid.grossman@neterion.com>
Subject: RE: [ANNOUNCE] Experimental Driver for Neterion/S2io 10GbE Adapters
Date: Mon, 14 Mar 2005 12:53:57 -0800
Message-ID: <200503142054.j2EKs2DD003697@guinness.s2io.com>
References: <20050314123815.73e7ee78.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>, <leonid@neterion.com>, <jgarzik@pobox.com>
To: "'David S. Miller'" <davem@davemloft.net>, <alex@neterion.com>
In-Reply-To: <20050314123815.73e7ee78.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi David,
S2io and Neterion is the same company, we just got our Company name changed
recently. 
So, the non-HAL version of this driver is in fact "s2io" driver in the
kernel - sorry we did not make it clear in the readme file.

I've seen in the past layered architectures for MAC drivers that resulted in
a performance hit, so this was a significant concern for me as well - for
10GbE product performance is an overwriting objective.

We compared performance results of the HAL-based driver vs. monolithic
approach on multiple platforms, and did not see any performance delta that
could be attributed to the approach itself. In fact, in some cases this
experimental driver faster - but I assume this is due to the lessons we
learned not the layered approach itself; performance-wise I see it as a
draw.

Do you have other objections to the submission? We'd like to see if these
could be addressed; going forward we see significant benefits both for
S2io/Neterion (and our customers) and for community to use this driver.

Regards, Leonid

-----Original Message-----
From: David S. Miller [mailto:davem@davemloft.net] 
Sent: Monday, March 14, 2005 12:38 PM
To: alex@neterion.com
Cc: netdev@oss.sgi.com; leonid@neterion.com; jgarzik@pobox.com
Subject: Re: [ANNOUNCE] Experimental Driver for Neterion/S2io 10GbE Adapters

On Mon, 14 Mar 2005 12:22:51 -0800
"Alex Aizman" <alex@neterion.com> wrote:

> For these reviewers who consider this a minus, we hope you will find the
HAL
> code in full compliance with Linux guidelines (in fact, it was written by
> our Linux team). Performance-wise, there was no negative impact discovered
> either. Testing-wise, this HAL has undergone numerous stress, functional,
> and performance tests "under" different drivers on a variety of platforms.

So you wrote a non-HAL version of this driver and compared the
results?  Simply comparing against the existins s2io driver
does not count.

If you're simply comparing against s2io, and your driver is faster
than s2io is already, imagine how much faster it might be without
that HAL layer.

I totally reject this driver, HAL is unacceptable for in-tree drivers.
We've been over this a thousand times.
