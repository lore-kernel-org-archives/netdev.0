From: Chris Friesen <cfriesen@nortelnetworks.com>
Subject: question about bridging/tunneling
Date: Wed, 22 Jan 2003 17:12:06 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3E2F1736.500@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I would like to take two physically separated networks and bridge them 
with some kind of tunnel over a third network.  What I suspect will be 
the tricky bit is that the two networks are both on the same subnet.

The topology will be something like this:


                     tunnel box 1
192.168.1.0/24 ---  47.129.x.x
(part of it)              |
                           | (network)
                           |
                           |
192.168.1.0/24 --- 47.129.x.y
(rest of it)        tunnel box 2

How would I go about doing this with a linux box at each end?  Security 
isn't really a concern now, quick and dirty is fine.

I was hoping for some way to make the two tunnel boxes and the tunnel 
itself act like an invisible bridge, without needing any 192 addresses.

The key thing here is that I can't change the routing on the other 
machines, so the tunnel boxes are going to have to proxy arp for the 
machines on the other end of the tunnel.

Any pointers on how to do this or where to look for docs?

Thanks,

Chris


-- 
Chris Friesen                    | MailStop: 043/33/F10
Nortel Networks                  | work: (613) 765-0557
3500 Carling Avenue              | fax:  (613) 765-2986
Nepean, ON K2H 8E9 Canada        | email: cfriesen@nortelnetworks.com
