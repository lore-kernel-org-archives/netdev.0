From: Larry Finger <larry.finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: ieee80211 sleeping in invalid context
Date: Tue, 12 Dec 2006 12:31:58 -0600
Message-ID: <457EF59E.8050001@lwfinger.net>
References: <455B63EC.8070704@madrabbit.org> <455F58AC.3030801@lwfinger.net>
	<457E2AE2.1020108@madrabbit.org> <200612121014.30309.mb@bu3sch.de>
	<457EEC1E.9000806@madrabbit.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>, Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Ray Lee <ray-lk-0Cg02Ec9UG4BXFe83j6qeQ@public.gmane.org>
In-Reply-To: <457EEC1E.9000806-0Cg02Ec9UG4BXFe83j6qeQ@public.gmane.org>
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

Ray Lee wrote:
> Michael Buesch wrote:
>> Congratulations to your decision ;)
> 
> Sometimes making decisions via Brownian motion has its advantages.
> 
>> Which kernel are you using?
> 
> Hmm, I'm using the mercurial repository, let me see if I can translate that to a git
> head... Looks like git tree c2bb88baa52429b6b76e3ba4272cb2b29713c5a8 . (Which is from
> less than 24 hours ago.)
> 
>> There is some locking breakage in latest kernels with softmac.
>> I attached the fixes for the known bugs.
> 
> Okay, I'll apply to my local copy, rebuild, and try again. I'll let you know what
> happens.

Please note that the 3rd hunk of the second patch that Michael sent is already in Linus's 
2.6.19-gitXX tree. You may get that part rejected by patch.

Larry
