From: Jamal Hadi Salim <hadi@znyx.com>
Subject: Re: Fw: issues with SO_PRIORITY and IP_TOS
Date: 04 Nov 2003 11:04:26 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1067961866.1031.41.camel@jzny.localdomain>
References: <200311041233.PAA15518@yakov.inr.ac.ru>
Reply-To: hadi@znyx.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, jmorris@redhat.com,
        cfriesen@nortelnetworks.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alexey <kuznet@ms2.inr.ac.ru>
In-Reply-To: <200311041233.PAA15518@yakov.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
I agree with Alexey in regards to DSCP should be done by classifiers.
Current mode of operation is: Whatever DSCP value you set will be reset
by the network/box manager depending on some criteria they set.  
Applications running as root or sudo can of course open a netlink
connection and set these values via a classifier.

Actually one important thing easy to miss is that the IEEE priorities
are reverse to what the IETF priorities are (who would have thunk, eh?).
I havent looked at the VLAN code however blindly using the
sk/skb->priority is _bad_ given that sk/skb->priority is based on IETF
semantics. I bet you the Linux vlan code doesnt know this.

cheers,
jamal
