From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: bcm43xx regression 2.6.19rc3 -> rc5, rtnl_lock trouble?
Date: Sat, 18 Nov 2006 11:05:08 -0600
Message-ID: <455F3D44.4010502@lwfinger.net>
References: <455B63EC.8070704@madrabbit.org>
	<20061118112438.GB15349@nineveh.rivenstone.net>
	<1163868955.27188.2.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm-3NddpPZAyC0@public.gmane.org>, Ray Lee <ray-lk-0Cg02Ec9UG4BXFe83j6qeQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Joseph Fannin <jhf-rN3PHIWzTs1Jm/Hvfsr4+Q@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>, Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
In-Reply-To: <1163868955.27188.2.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
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

Johannes Berg wrote:
> On Sat, 2006-11-18 at 06:24 -0500, Joseph Fannin wrote:
> 
>>     This sounds like what my laptop was doing in -rc5, though mine
>> didn't take hours to start acting up.
>>
>>     I *think* it was the MSI troubles, causing interrupts to get
>> lost forever.  Anyway, it went away in -rc6.
> 
> Hah, that's a lot more plausible than bcm43xx's drain patch actually
> causing this. So maybe somehow interrupts for bcm43xx aren't routed
> properly or something...
> 
> Ray, please check /proc/interrupts when this happens.
> 
> I am convinced that the patch in question (drain tx status) is not
> causing this -- the patch should be a no-op in most cases anyway, and in
> those cases where it isn't a no-op it'll run only once at card init and
> remove some things from a hardware-internal FIFO.

I agree that drain tx status should not cause the problem.

Ray, does -rc6 solve your problem as it did for Joseph?

Larry
