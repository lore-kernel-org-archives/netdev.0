From: chas williams (contractor) <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH] (1/5) replay netdev notifier events on registration
Date: Thu, 15 Jan 2004 22:19:29 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401160319.i0G3JSRr017497@ginger.cmf.nrl.navy.mil>
References: <20040115004255.62dc8b95.davem@redhat.com>
Reply-To: chas3@users.sourceforge.net
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-reply-to: Your message of "Thu, 15 Jan 2004 00:42:55 PST."
             <20040115004255.62dc8b95.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In message <20040115004255.62dc8b95.davem@redhat.com>,"David S. Miller" writes:
>2) Add a type cookie or similar to the generic netdev, only devices
>   which need to identify themselves in these generic kind of cases
>   add identifier values there, so currently that would be MPOA and
>   QETH, then the code goes:
>
>	if (dev->type_cookie == NETDEV_TYPE_MPOA)
>		return NOTIFY_DONE;

while just as ugly it would probably suffice to check dev->start_xmit()
to make sure its the routine you know it should be.  since the number 
of drivers that need to do this seems small this might be simpler.
