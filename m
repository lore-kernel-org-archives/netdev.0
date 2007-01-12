From: Larry Finger <larry.finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH V2] bcm43xx: Fix failure to deliver PCI-E interrupts
Date: Fri, 12 Jan 2007 13:27:33 -0600
Message-ID: <45A7E125.8030009@lwfinger.net>
References: <45a7ceb2.m02aaCgouBsadVk/%Larry.Finger@lwfinger.net>	<9b3e2dc20701121050p52e13d92r1ec78e1881bbed3@mail.gmail.com>
	<200701122001.45546.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
In-Reply-To: <200701122001.45546.mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> On Friday 12 January 2007 19:50, Stephen Sinclair wrote:
>>> The PCI-E modifications to bcm43xx do not set up the interrupt vector
>>> correctly. Tested with BCM4311 (PCI-E) on x86_64 and BCM4306 (PCI) on i386.
>> This was successful for me.  My 4311 is now getting interrupts, and I
>> was able to successfully associate with an AP.  (i386)
> 
> That does the (i386) mean here?
> Were you able to accociate with your PCI or PCI-E card?

Stephen has an i386 system with a PCI-E 4311. The PCI card on i386 was mine, which I tested to make
sure the logic change didn't break the old systems. The display on my old laptop died and wasn't
worth fixing; however, I ssh into it to test on a PCI system.

Larry
