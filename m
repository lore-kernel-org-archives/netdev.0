From: Harley Stenzel <hstenzel@us.ibm.com>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Tue, 19 Aug 2003 17:01:45 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F429039.8090905@us.ibm.com>
References: <353568DCBAE06148B70767C1B1A93E625EAB57@post.pc.aspectgroup.co.uk>	<070c01c36653$7f3c1ab0$c801a8c0@llewella>	<20030819083438.26c985b9.davem@redhat.com>	<20030819173920.GA3301@marowsky-bree.de> <20030819103613.4485e549.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Lars Marowsky-Bree <lmb@suse.de>, bloemsaa@xs4all.nl,
   richard@aspectgroup.co.uk, skraw@ithnet.com, willy@w.ods.org,
   alan@lxorguk.ukuu.org.uk, carlosev@newipnet.com, lamont@scriptkiddie.org,
   davidsen@tmr.com, marcelo@conectiva.com.br, netdev@oss.sgi.com,
   linux-net@vger.kernel.org, layes@loran.com, torvalds@osdl.org,
   linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030819103613.4485e549.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> 
> And, as Alan said, we provide a way for one to obtain your networking
> religion of week.

To the best of my knowledge, there is presently no way to change the arp 
behavior of Linux such that it uses the interface-based arp mechanizm in 
  a manner compatable with load-balancing and hot-standby techniques 
involving aliasing the loopback interface.  In all the proposed 
solutions the cache-update by an arp request problem still exists (arp 
source ip problem).

I would love to be proven wrong.  Presently I have to either patch the 
kernel or suffer the throughput penalty of doing dnat to myself, all to 
do something that Solaris, AIX, HP-UX, *BSD, and even Windows can do 
natively.

--Harley
