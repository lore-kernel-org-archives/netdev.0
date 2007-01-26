From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH] bcm43xx-d80211: Interrogate hardware-enable switch and
	update LEDs
Date: Fri, 26 Jan 2007 10:01:20 +0100
Message-ID: <200701261001.20677.mb@bu3sch.de>
References: <459749bb.q8/+AsgXLhurTs3u%Larry.Finger@lwfinger.net>
	<20070126024451.GK10282@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20070126024451.GK10282-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
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

On Friday 26 January 2007 03:44, John W. Linville wrote:
> On Sat, Dec 30, 2006 at 11:25:15PM -0600, Larry Finger wrote:
> > The current bcm43xx driver ignores any wireless-enable switches on mini-PCI
> > and mini-PCI-E cards. This patch implements a new routine to interrogate the
> > radio hardware enabled bit in the interface, logs the initial state and any
> > changes in the switch (if debugging enabled), activates the LED to show the
> > state, and changes the periodic work handler to provide 1 second response
> > to switch changes and to account for changes in the periodic work specs. It
> > also incorporates changes in the LED state that were accepted into mainline
> > some time ago.
> 
> Larry,
> 
> I wanted to merge this, but a slew of changes pulled from Michael
> makes this patch fail to apply.

Hm? What did you pull?

-- 
Greetings Michael.
