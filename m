From: Mauro Tortonesi <mauro@ferrara.linux.it>
Subject: Re: Fwd: Question about kernel and IPv6...
Date: Wed, 23 Oct 2002 13:29:00 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0210231319250.11284-100000@trantor.ferrara.linux.it>
References: <1035360350.3db6585e0bdce@webmail.debianlinux.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: michael@albog.dk
In-Reply-To: <1035360350.3db6585e0bdce@webmail.debianlinux.dk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 23 Oct 2002 michael@albog.dk wrote:

> - What kernel version have most IPv6 features build-in ?? (Maybe a feature is 
> missing in 2.4.19. I have read an article about patching the kernel: 
> http://project6.ferrara.linux.it/papers/best_ipv6_support_4_linux/best_ipv6_supp
> ort_4_linux.html, it is necessary?).

micheal, that article is a bit obsolete. i will update it as soon as 
possible, but until next week there is no chance i can do it (friday i 
will get my MS degree in electronic engineering and i am __very__ busy 
now).

however, the choice of the kernel to use is quite simple: if you need the 
advanced features in usagi kernel (e.g. ISATAP, drop packets with fake 
ipv4-mapped address, RFC 3041 support, anycast support, allow default 
route when forwarding is enabled, Node Information Queries, IPSEC, MIPv6, 
IPv6-in-IPv6 tunneling) you should install the usagi kit. if not, use the 
standard vanilla kernel.


p.s. i wouldn't spend too much time working on ripng. if you wish 
     to analyze routing protocols, perhaps OSPF and BGP4+ would be 
     better choices.

-- 
Aequam memento rebus in arduis servare mentem...

Mauro Tortonesi			mauro@ferrara.linux.it
				mauro.tortonesi@ing.unife.it
Ferrara Linux Users Group	http://www.ferrara.linux.it
Project6 - IPv6 for Linux	http://project6.ferrara.linux.it
