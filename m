From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH] bcm43xx-softmac: improve wrong firmware message
Date: Thu, 14 Sep 2006 10:00:40 -0400
Message-ID: <20060914140034.GB27558@tuxdriver.com>
References: <45071890.mailJEJ1PQOHG@lwfinger.net> <20060912214939.GA3750@tuba>
	<45072F4D.80109@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Martin Langer <martin-langer-Mmb7MZpHnFY@public.gmane.org>,
	Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>,
	Stefano Brivio <st3-sGOZH3hwPm2sTnJN9+BGXg@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <45072F4D.80109-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
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

On Tue, Sep 12, 2006 at 05:06:05PM -0500, Larry Finger wrote:
> Martin Langer wrote:
> >
> >Why not writing both (ucode rev and driver version)? Something like 
> >
> >	"from version 4.x binary drivers (rev>0x128).\n"
> >
> >BTW, if anybody needs the relationship between ucode revsion and driver 
> >version then he should look at the table here:
> >
> >http://www.langerland.de/linux/bcm43xx/firmware.html
> 
> I could do that; however, I think this error message may have a short life 
> as I'm just now looking at Michael's v4 firmware revisions for d80211 with 
> an eye toward porting them to softmac.
> 
> John - what do you think?

Let's just take the new/current patch as-is.  Someone who understands
"rev > 0x128" should be able to find the message in the code for
himself... :-)

John
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
