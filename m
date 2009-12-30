From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: sky2 panic in 2.6.32.1 under load (new oops)
Date: Wed, 30 Dec 2009 10:36:33 -0500
Message-ID: <4B3B7381.9050408@majjas.com>
References: <4B300A2A.8040305@gmail.com> <4B300E30.9090707@majjas.com>
 <4B3114E3.1070602@majjas.com> <4B329FA3.9090904@majjas.com>
 <20091223230102.4bb0100e.akpm@linux-foundation.org>
 <20091230000724.4083e7dd@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"Berck E. Nash" <flyboy@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752055AbZL3PhN@vger.kernel.org>
In-reply-to: <20091230000724.4083e7dd@nehalam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

What has been running on eth0 (usual for me ... perhaps relevant to the 
issue) when I've seen the errors. As noted previously, there is a 
correlation with dhcp, and maybe one with dns over ipv6.

Console is local (nouveau kms).

As per Stephen's other email, I'm rerunning with kernel debug enabled. 
I'll also try nomodeset and could if need by (but a real PITA) can swap 
video cards with an ATI card.

ipv6
appletalk
dhcpd
smb
dns (bind9)
X11 (accessing box via cygwin)
sendmail
imap
mediatomb
On 12/30/2009 3:07 AM, Stephen Hemminger wrote:
> On Wed, 23 Dec 2009 23:01:02 -0800
> Andrew Morton<akpm@linux-foundation.org>  wrote:
>
>    
>>> Dec 23 17:32:58 mail kernel: DRHD: handling fault status reg 2
>>> Dec 23 17:32:58 mail kernel: DMAR:[DMA Read] Request device [06:00.0]
>>> fault addr fff8423fe000
>>> Dec 23 17:32:58 mail kernel: DMAR:[fault reason 06] PTE Read access is
>>> not set
>>> Dec 23 17:32:58 mail kernel: sky2 0000:06:00.0: error interrupt
>>> status=0x80000000
>>> Dec 23 17:32:58 mail kernel: sky2 0000:06:00.0: PCI hardware error (0x2010)
>>> Dec 23 17:33:06 mail kernel: ------------[ cut here ]------------
>>> Dec 23 17:33:06 mail kernel: WARNING: at net/sched/sch_generic.c:255
>>> dev_watchdog+0xf3/0x161()
>>> Dec 23 17:33:06 mail kernel: Hardware name: System Product Name
>>> Dec 23 17:33:06 mail kernel: NETDEV WATCHDOG: eth0 (sky2): transmit
>>>        
> Just to reiterate, these are consistent with a DMA error on transmit.
> Since is 4 seconds after the DHCPACK, they probably are not related, except
> that when DHCP renew may have caused more traffic.
>
> Are you using something like network console or kgdb, or anything that could
> be using some unusual network I/O?
>    
