From: kuznet@ms2.inr.ac.ru
Subject: Re: Fw: issues with SO_PRIORITY and IP_TOS
Date: Thu, 13 Nov 2003 14:08:00 +0300 (MSK)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311131108.OAA24780@yakov.inr.ac.ru>
References: <3FAA5FF6.50509@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, jmorris@redhat.com, hadi@znyx.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: cfriesen@nortelnetworks.com (Chris Friesen)
In-Reply-To: <3FAA5FF6.50509@nortelnetworks.com> from "Chris Friesen" at Ноя 06, 2003 09:51:34 
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> I would like to send a vlan tagged packet, with vlan priority of x and 
> DSCP field of (x<<5).  What is the proper way to do this, if I should 
> not be using skb->priority?

To set DSCP field you set the thing known as TOS with IP_TOS.

To set VLAN priority, you tune VLAN f.e. to use DSCP bits in classifier
to derive VLAN priority from those bits of DSCP, which you desire. DSCP>>5
in your case.


And remember that if the box is DS aware, DS will rewrite your DSCP
in the way consistent with sustem configuration.

Alexey
