From: "evan foss" <evanfoss-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH V2] bcm43xx: Fix failure to deliver PCI-E interrupts
Date: Fri, 12 Jan 2007 14:18:51 -0500
Message-ID: <4a55afb80701121118r342ec98s8b3312b8c7e59e85@mail.gmail.com>
References: <45a7ceb2.m02aaCgouBsadVk/%Larry.Finger@lwfinger.net>
	<200701121953.44630.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
In-Reply-To: <200701121953.44630.mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Content-Disposition: inline
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

> This hunk is OK, but I just want to point out that bustype is
> always equal to BCM43xx_BUSTYPE_PCI ;)
> The 0x53 timeouts are for an SSB-BUS.
> So strictly said this hunk is a NOP.
>
> The other hunks are OK, too. They fix real bugs.
> Thanks for spotting them, Larry!

So then what fixed int's for Stephen Sinclair? Or did they already
work? I would gladly help test I knew it applied to me.

>> The PCI-E modifications to bcm43xx do not set up the interrupt vector
>> correctly. Tested with BCM4311 (PCI-E) on x86_64 and BCM4306 (PCI) on i386.
>
>This was successful for me.  My 4311 is now getting interrupts, and I
>was able to successfully associate with an AP.  (i386)


-- 
http://www.coe.neu.edu/~efoss/
http://evanfoss.googlepages.com/
