From: Michael Renzmann <mrenzmann@web.de>
Subject: Re: Where Linux 802.11x support needs work
Date: Wed, 26 Jan 2005 08:17:10 +0100
Message-ID: <41F743F6.2020008@web.de>
References: <20050126024039.GA25326@bougret.hpl.hp.com> <Pine.LNX.4.58.0501252224000.4275@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jean Tourrilhes <jt@hpl.hp.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <Pine.LNX.4.58.0501252224000.4275@devserv.devel.redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi.

Dan Williams wrote:
> madwifi: doesn't seem to implement SIOCGIWSTATS

It does. The SIOCGIWSTATS is used in tools/athstats.c (line 195 in 
current CVS) for example to get the rssi (via qual.qual).

>>>o  Ad-Hoc mode support is quite flaky or absent from most drivers
>>	Low priority for most vendors, firwmares are only lightly tested.
> Yeah, I don't expect much to happen here but it would be nice.  FWIW, at 
> least madwifi and atmel seem to work OK here.

Madwifi unfortunately has some known problems in Ad-hoc implementation. 
Someone worked on that, but the patches have not been sent in as far as 
I can tell.

>>	Note that various other people have their own todo list. Jeff
>>also has things he has in minds. I have (few) patches on my web
>>pages. Driver authors also have their wishes.
> True, but I'm not sure how many of those wishes/todo lists are actually 
> well-known or public.  I don't really see any great momentum in the Linux 
> 802.11x world, but more a hodge-podge of improvements.  I was hoping that 
> the post today could help  direct a bit more attention and effort at Linux 
> 802.11x stuff so we could try to clean it up and improve it.

How about setting up a project that cares of finding, defining and 
implementing such quasi-standards in the Linux 802.11 world? Most things 
are very WLAN specific, so I think netdev isn't the best place to 
discuss them. Of course this only works IMO when many (if not all) of 
the wlan driver authors join in and help out.

Comments?

Bye, Mike
