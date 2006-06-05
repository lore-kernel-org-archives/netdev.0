From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH, RTF/RFC] bcm43xx: Enable local IRQs while executing periodic work
Date: Mon, 5 Jun 2006 21:13:31 +0200
Message-ID: <200606052113.31629.mb@bu3sch.de>
References: <200605231723.10028.mb@bu3sch.de> <20060605185433.GF6068@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
   "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <bcm43xx-dev-admin-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20060605185433.GF6068-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Content-Disposition: inline
To: "Undisclosed.Recipients": ;
Sender: bcm43xx-dev-admin-tdrK/OAtAx2ELgA04lAiVw@public.gmane.org
Errors-To: bcm43xx-dev-admin-tdrK/OAtAx2ELgA04lAiVw@public.gmane.org
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Subscribe: <http://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
List-Unsubscribe: <http://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.berlios.de/pipermail/bcm43xx-dev/>
List-Id: netdev.vger.kernel.org

On Monday 05 June 2006 20:54, John W. Linville wrote:
> On Tue, May 23, 2006 at 05:23:09PM +0200, Michael Buesch wrote:
> 
> > I would like to get this into wireless-2.6, but before that
> > happens I would like to have a few regression tests by people.
> > Please apply this and run high network traffic for 10-15 minutes.
> > Please enable kernel spinlock lockup and recursion detection
> > while testing.
> 
> It has almost been two weeks...do we want this patch, or not?

The two patches
[PATCH 1/2] bcm43xx: redesign locking
[PATCH 2/2] bcm43xx: preemptible periodic work
are the successors of it. ;) So, no, I don't want that old
and broken patch any longer.

But thanks that you asked. I forgot about it.

-- 
Greetings Michael.
