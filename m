From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: Re: [RFC] locking changes for lec.c
Date: Fri, 14 Jan 2005 21:32:51 -0500
Message-ID: <200501150232.j0F2Wovr010942@ginger.cmf.nrl.navy.mil>
References: <20050114135612.0edc180d.davem@davemloft.net>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-reply-to: Your message of "Fri, 14 Jan 2005 13:56:12 PST."
             <20050114135612.0edc180d.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In message <20050114135612.0edc180d.davem@davemloft.net>,"David S. Miller" writes:
>Can HW interrupt paths ever call into this ARP stuff?
>If not, probably should just use BH disabled locking
>instead of the heavy handed IRQ disabling locks.

yes, lec_push() could be run in hw interrupt context from one of of the
atm drivers recv path.  in fact, this is the path where i "noticed" the
race condition.
