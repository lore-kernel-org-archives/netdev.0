From: Chris Friesen <cfriesen@nortelnetworks.com>
Subject: firewalling PPPOE stream without terminating it
Date: Fri, 12 Sep 2003 10:32:04 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F61D8E4.6020309@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I've got a PPPOE DSL line coming into my house, and I and my roommates 
each terminate our own connection and get our own dynamic IP address.

With the recent bunch of viruses/worms, a couple of us were thinking 
about setting up a box as a transparent firewalling bridge.  The only 
tricky bit is that we don't want to terminate the PPPOE connection at 
that box, since that would then force us to do NAT/ipmasq.

Does anyone know of any way to filter the contents of a tunnelled packet 
(PPPOE in particular) using standard tools like ebtables/iptables?

The other possibility I had considered was a netfilter module that tied 
into the ebtables hooks and knew how to look inside the PPPOE packet, 
but then I wouldn't get the userspace interface from ebtables/iptables.

Chris

-- 
Chris Friesen                    | MailStop: 043/33/F10
Nortel Networks                  | work: (613) 765-0557
3500 Carling Avenue              | fax:  (613) 765-2986
Nepean, ON K2H 8E9 Canada        | email: cfriesen@nortelnetworks.com
