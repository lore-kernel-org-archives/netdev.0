From: Vincent Guffens <guffens@auto.ucl.ac.be>
Subject: Re: Do you know the linux TCP stack?
Date: Sat, 05 Mar 2005 17:34:31 +0100
Message-ID: <4229DF97.2040500@auto.ucl.ac.be>
References: <E1D7aML-0007Wp-00@smtp01.mrf.mail.rcn.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
To: Zdenek Radouch <zdenek@rcn.com>
In-Reply-To: <E1D7aML-0007Wp-00@smtp01.mrf.mail.rcn.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Zdenek Radouch wrote:
> I ran out of ideas.  Can't find the answers in any docs,
> and I don't have time to read and analyze the source right now.
> 
> I will hire you to help me; I need the following to be done in
> my net device driver:
> 
> With the ARP disabled (this is well documented so I believe I've done that),
> while queueing the physical output, I need to get hold of the IP address
> of where the packet is being sent.  Yes, I mean IP address, not
> Ethernet address, and yes this is not the destination addresses in
> the IP header.

can you not use the routing table ? In a normal setup, either the 
network part of your destination IP matches the network part of a 
directly connected network and the address your are looking for is the 
destination IP in the packet or it does not match and the next IP is the 
  IP of the gateway found by routing.

Is it what you are looking for ?


-- 
				Vincent Guffens
				PhD Student UCL/CESAME
				tel:   +32 10 47 80 30
Value your freedom, or you will lose it, teaches history.
"Don't bother us with politics," respond those who don't want to learn.
	      	-- Richard M. Stallman
