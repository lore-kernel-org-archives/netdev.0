From: Jason Lunz <lunz@falooley.org>
Subject: Re: A better way to get driver stats than parsing /proc/net/dev ?
Date: Fri, 11 Apr 2003 15:19:52 +0000 (UTC)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <slrnb9dn9r.fef.lunz@stoli.localnet>
References: <3E967535.2000409@candelatech.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

greearb@candelatech.com said:
> Is there an ioctl or some other binary means of getting the info that
> /proc/net/dev provides?

You can do it with netlink sockets. See print_linkinfo() in the iproute2
code.

Jason
