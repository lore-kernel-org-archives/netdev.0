From: Chris Friesen <cfriesen@nortelnetworks.com>
Subject: any plans for a really lowlevel netfilter hook?
Date: Mon, 08 Sep 2003 15:43:26 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F5CDBDE.8000604@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I've got a wn2k session running in vmware configured with bridged 
ethernet.  In this mode, windows accessses the hardware and gets a 
separate IP address from the linux host.  I assume that it's done 
through a packet socket or something like that.

Anyways, I had been hoping to be able to filter the packets, but it 
seems that they get pulled off before they hit the ip stack, and so 
iptables is useless.

ebtables seems to only affect bridged stuff, so I don't think that it 
would be applicable either.

What I'd like would be some kind of netfilter hook really early and 
really late (before and after packet sockets, respectively).  Any plans 
for such?

Chris

-- 
Chris Friesen                    | MailStop: 043/33/F10
Nortel Networks                  | work: (613) 765-0557
3500 Carling Avenue              | fax:  (613) 765-2986
Nepean, ON K2H 8E9 Canada        | email: cfriesen@nortelnetworks.com
