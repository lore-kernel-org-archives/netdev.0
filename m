From: Joe Perches <joe@perches.com>
Subject: Re: [RESEND PATCH 0/2] Make functions of dev_<level> macros,
 recursive vsnprintf
Date: Sat, 06 Mar 2010 13:36:39 -0800
Message-ID: <1267911399.849.39.camel@Joe-Laptop.home>
References: <cover.1267682641.git.joe@perches.com>
	 <20100304143837.af39845d.akpm@linux-foundation.org>
	 <alpine.LFD.2.00.1003041504080.3751@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Nick Andrew <nick@nick-andrew.net>,
	linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@suse.de>,
	netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1003041504080.3751@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-03-04 at 15:06 -0800, Linus Torvalds wrote:
> On Thu, 4 Mar 2010, Andrew Morton wrote:
> > What would I need to do to make it recur more than once?  Include a %pV
> > in a string, like dev_printk("%s", %%pV")?
> 
> I would argue that if somebody does that, they're just broken.
> 
> The single level of recursion is really nice - it solves a real annoyance. 
> But if somebody starts trying to do multiple levels, that's just crazy.
> 
> Of course, I guess we don't relly have any way of sanely _counting_ the 
> recursion level, so we'd have to just trust people to not do crazy things. 
> 
> And that's a big thing to take on trust ;)

Is that an ack, a nack or a get the hell out?
