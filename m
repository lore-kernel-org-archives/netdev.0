From: Chris Friesen <cfriesen@nortelnetworks.com>
Subject: Re: Fw: issues with SO_PRIORITY and IP_TOS
Date: Thu, 06 Nov 2003 09:51:34 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FAA5FF6.50509@nortelnetworks.com>
References: <200311060931.MAA14771@yakov.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, jmorris@redhat.com, hadi@znyx.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

kuznet@ms2.inr.ac.ru wrote:

> What's about VLAN thing, this approach enforces you to use
> DSCP directly and never use skb->priority (well, to be more exact,
> to use it when you have no another hints available: in this case
> our skb->priority is _right_ hint)

Okay, maybe you can help me out then.

I would like to send a vlan tagged packet, with vlan priority of x and 
DSCP field of (x<<5).  What is the proper way to do this, if I should 
not be using skb->priority?

Chris

-- 
Chris Friesen                    | MailStop: 043/33/F10
Nortel Networks                  | work: (613) 765-0557
3500 Carling Avenue              | fax:  (613) 765-2986
Nepean, ON K2H 8E9 Canada        | email: cfriesen@nortelnetworks.com
