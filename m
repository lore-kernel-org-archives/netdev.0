From: "Patrick R. McManus" <mcmanus@ducksong.com>
Subject: Re: netlink sockets and rtm_newlink messages
Date: Fri, 27 Sep 2002 09:48:06 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020927134806.GA12745@ducksong.com>
References: <20020926223853.GA4062@ducksong.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20020926223853.GA4062@ducksong.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

for the sake of google, I'll followup to my own query. Sanity checks
are appreciated too.

the messages weren't identical - ifi_change had IFF_RUNNING set in one
message and not the other. the man page says "ifi_change is reserved
for future use" so I didn't know what to make of it before digging
into the kernel src (2.4.19).

-Pat

[pat atducksong: Sep 26 18:38]
> hello -
> 
> I've got a little userspace app that listens to a netlink socket and
> filters for messages of type RTM_NEWLINK to check for interfaces going
> up or down (checking ifi_flags to make that determination)..
> 
> the only stumbling point is that I each time I do something like
> "ifconfig eth4 down" my app reads 2 identical RTM_NEWLINK messages
> instead of one (same behavior on up case too.)
> 
> any thoughts on why? I didn't really know how to interpret sockaddr
> nl.nl_groups.. 1 seems to give me the same duplicates as ~0.. 0 gives me nothing.
> 
> 
> -Pat
> 
