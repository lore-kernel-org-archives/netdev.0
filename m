From: "Patrick R. McManus" <mcmanus@ducksong.com>
Subject: netlink sockets and rtm_newlink messages
Date: Thu, 26 Sep 2002 18:38:53 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020926223853.GA4062@ducksong.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

hello -

I've got a little userspace app that listens to a netlink socket and
filters for messages of type RTM_NEWLINK to check for interfaces going
up or down (checking ifi_flags to make that determination)..

the only stumbling point is that I each time I do something like
"ifconfig eth4 down" my app reads 2 identical RTM_NEWLINK messages
instead of one (same behavior on up case too.)

any thoughts on why? I didn't really know how to interpret sockaddr
nl.nl_groups.. 1 seems to give me the same duplicates as ~0.. 0 gives me nothing.


-Pat
