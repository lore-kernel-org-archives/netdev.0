From: John Zwiebel <John.Zwiebel@procket.com>
Subject: [Fwd: Re: IGMPv3 in linux]
Date: Wed, 15 May 2002 13:39:50 -0700
Sender: owner-netdev@oss.sgi.com
Message-ID: <3CE2C796.B18FB3E2@Procket.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <owner-netdev@oss.sgi.com>
To: netdev@oss.sgi.com, jzwiebel@procket.com
List-Id: netdev.vger.kernel.org


When will IGMPv3 be standard in Linux?
What can I do to make it happen sooner?
Who should I contact?

IGMPv3 is in Windows XP.  IGMPv3 is required for general Source 
Specific Multicast (SSM).  SSM across the internet is much 
more reliable than MSDP/PIM/MBGP (ASM: any source multicast).
Although Microsoft doesn't yet have an IGMPv3 application, IP/TV
from cisco will be (does already, at least in a beta app) use it.
There are a number of Linux applications that use it, but since
it requires a special kernel installation, many people who would
benefit from SSM are now denied.  

I am working also to get IGMPv3 into FreeBSD from which it
should "automagically" get into Opendarwin and then MacOSX.

Thanks

John Zwiebel

-------- Original Message --------
Subject: Re: IGMPv3 in linux
Date: Wed, 15 May 2002 21:36:43 +0100 (BST)
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
To: jzwiebel@procket.com (John Zwiebel)

Long time since I was involved in the net code. I believe IGMPv3 is
still
not in the kernel. Dunno if its planned - ask netdev@oss.sgi.com
