From: Matthew Galgoci <mgalgoci@redhat.com>
Subject: Re: Device naming for wireless NICs...
Date: Thu, 11 Mar 2004 11:54:40 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0403111146240.21414-100000@lacrosse.corp.redhat.com>
References: <405093A7.90209@linux.co.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Ketrenos <jketreno@linux.co.intel.com>
In-Reply-To: <405093A7.90209@linux.co.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 11 Mar 2004, James Ketrenos wrote:

> 
> If this topic been hashed a lot already, please let me know the keywords I might 
> search for in the archives to find the threads.
> 
> I've had a few requests by users of the IPW2100 wireless driver to switch the 
> default interface name to be wlanX vs. ethX.  In my prior searches through the 
> wireless drivers in the 2.6.3 kernel tree, I couldn't find any that changed from 
> the default.
> 
> I don't mind adding a module parameter to change the default name (if that is 
> the standard practice), but thought I'd see what others thing rather than just 
> going off and doing something random.
> 
> Is there a technical or ease of use reason switching away from ethX?  My 
> thinking in keeping it eth was that it then represents a greater chance of "just 
> working" with most networking scripts and utilities that may assume ethX is the 
> interface name.

TBH I don't think it much matters. I know that at least Red Hat's networking scripts 
(and possibly other distributions) did at one point assume that each interface would 
be named ethX, but I don't think that is the case anymore.

Some drivers even present both a wlanX and an ethX interface, which I think is an atavism
that goes back to networking scripts breaking horribly on non-ethX interface names.

Going forward it might be worth while to standardize all wireless interface names, just
to show at a glance that an interface is 802.11x, and also to differentiate the fact that
eventually 802.11 will be its own network stack.

-- 
Matthew Galgoci
System Administrator
Red Hat, Inc
919.754.3700 x44155
