From: chas williams <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH][ATM] use rtnl_{lock,unlock} during device operations (take 2)
Date: Tue, 17 Jun 2003 13:52:32 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200306171754.h5HHsWsG000656@ginger.cmf.nrl.navy.mil>
References: <20030606.085558.56056656.davem@redhat.com>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-reply-to: Your message of "Fri, 06 Jun 2003 08:55:58 PDT."
             <20030606.085558.56056656.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In message <20030606.085558.56056656.davem@redhat.com>,"David S. Miller" writes
:
>   From: Werner Almesberger <wa@almesberger.net>
>   Date: Fri, 6 Jun 2003 12:54:16 -0300
>
>   (If you want to keep Chas busy, the communication between
>   the kernel and its demons may be a much more interesting
>   topic ;-)
>   
>Tell me it at least uses netlink ;(

so i was doing a bit of thinking about this netlink conversion for signalling
(and lane and clip and br2684).  would i create a new family for each like
NETLINK_SIGNALLING, NETLINK_LANE, or create a single new family NETLINK_ATM
and multiplex nlmsg_type, or use the existing NETLINK_USERSOCK?
