From: Chris Friesen <cfriesen@nortelnetworks.com>
Subject: Re: Fw: issues with SO_PRIORITY and IP_TOS
Date: Thu, 13 Nov 2003 12:48:30 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FB3C3EE.6040802@nortelnetworks.com>
References: <200311131108.OAA24780@yakov.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, jmorris@redhat.com, hadi@znyx.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

kuznet@ms2.inr.ac.ru wrote:

> To set VLAN priority, you tune VLAN f.e. to use DSCP bits in classifier
> to derive VLAN priority from those bits of DSCP, which you desire. DSCP>>5
> in your case.

Excellent.  How do I do this?  I know of the egress mapping of socket 
priority to vlan priority.  How do I map DSCP to vlan priority?

I know how to do this by setting the socket priority with another 
setsockopt call, but is there a way of doing this directly?

Chris



-- 
Chris Friesen                    | MailStop: 043/33/F10
Nortel Networks                  | work: (613) 765-0557
3500 Carling Avenue              | fax:  (613) 765-2986
Nepean, ON K2H 8E9 Canada        | email: cfriesen@nortelnetworks.com
