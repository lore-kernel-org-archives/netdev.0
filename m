From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] wext: handle NULL exta data in iwe_stream_add_point better
Date: Thu, 12 Jan 2017 10:44:16 +0100
Message-ID: <3158205.0GkzbOcZ01@wuerfel>
References: <20170111143532.485827-1-arnd@arndb.de> <3292373.oxnXTOSWCQ@wuerfel> <1484212560.5391.3.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-wireless@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1484212560.5391.3.camel@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, January 12, 2017 10:16:00 AM CET Johannes Berg wrote:
> And I realized only now that this was a different place ...

Right, it was a few hundred randconfigs later after I had confirmed
that the first patch fixed all the configurations that were broken
at first.

> I've just added the check you suggested - spent way too much time
> already on this old crap 

Ok, thanks! Let's hope it doesn't come back once more.

I'm still trying to categorize the newly added warnings in gcc-7,
there a number of very useful warnings that got added, but some of
them are rather noisy and find both a number of real bugs and
false positives. The NULL check had only a few findings that all
seemed worth fixing.

	Arnd
