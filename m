From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: RE: [2.4 PATCH] bugfix: ARP respond on all devices
Date: 19 Aug 2003 20:08:20 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1061320099.30567.55.camel@dhcp23.swansea.linux.org.uk>
References: <353568DCBAE06148B70767C1B1A93E625EAB58@post.pc.aspectgroup.co.uk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "'David S. Miller'" <davem@redhat.com>,
   Stephan von Krawczynski <skraw@ithnet.com>, willy@w.ods.org,
   carlosev@newipnet.com, lamont@scriptkiddie.org, davidsen@tmr.com,
   bloemsaa@xs4all.nl, Marcelo Tosatti <marcelo@conectiva.com.br>,
   netdev@oss.sgi.com, linux-net@vger.kernel.org, layes@loran.com,
   torvalds@osdl.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Richard Underwood <richard@aspectgroup.co.uk>
In-Reply-To: <353568DCBAE06148B70767C1B1A93E625EAB58@post.pc.aspectgroup.co.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Maw, 2003-08-19 at 15:34, Richard Underwood wrote:
> # arp -d 172.24.0.80
> # ping -I 172.20.240.2 172.24.0.80
> 
> 	I see:
> 
> 16:18:40.856328 arp who-has 172.24.0.80 tell 172.20.240.2
> 16:18:40.856431 arp reply 172.24.0.80 is-at 0:50:da:44:f:37

Fine

> 	But if I was to do this in the other direction (arp -d 172.20.240.1;
> ping -I 172.24.0.1 172.20.240.1) then I'd lose connectivity over my default
> route because 172.20.240.1 won't accept ARP packets from IP numbers not on
> the connected subnet. The <incomplete> ARP entry will block any further ARP
> requests from valid IP numbers.

One thing I agree with you about is that an ARP resolution for an
address via one path should not block a resolution for it by another
path since to begin with the two paths may be to different routers
one of which is down.
