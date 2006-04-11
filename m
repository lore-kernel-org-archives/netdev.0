From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: bcm43xx symbol clash problems
Date: Tue, 11 Apr 2006 18:35:03 +0200
Message-ID: <200604111835.03948.mb@bu3sch.de>
References: <200604100216.21571.mb@bu3sch.de> <1144737580.4888.25.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
   bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-admin-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
In-Reply-To: <1144737580.4888.25.camel@localhost>
Content-Disposition: inline
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

On Tuesday 11 April 2006 08:39, Johannes Berg wrote:
> On Mon, 2006-04-10 at 02:16 +0200, Michael Buesch wrote:
> > Does kbuild perhaps have some magic to handle that?
> > 
> > This needs to be solved soon, but I have no idea how.
> 
> You want to have bcm43xx and bcm43xx-dscape conflict anyway, since
> there's no point in building both into the kernel, only one can be bound
> to a device. Yes, I know one could still bind them manually, but that's
> about as icky as building them as modules imho. And whoever really needs
> a static kernel will not need both of them.
> 
> I don't know how the Kconfig there is laid out, but wouldn't it be
> possible to make them conflict on both yes?

Sure. I would probably say that both m should conflict, too.
And one y and the other m, too.
This can be done with ugly "depends" statements.

-- 
Greetings Michael.
