From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: bcm43xx symbol clash problems
Date: Mon, 10 Apr 2006 02:16:21 +0200
Message-ID: <200604100216.21571.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-admin-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
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

Hi,

I looked into the symbol clash problems between bcm43xx and bcm43xx-d80211
you mentioned at the wireless summit.
Well, IMHO it is pretty hard to find a good solution to this.
The situation is: We have several nonstatic functions in the bcm driver. These
functions have the same name in the softmac and dscape versions. It's quite a
lot of functions.
We can't make them static, because the driver is splitted over several files.
I would _really_ want to prevent renaming them all, because that is lots of work,
which will be thrown away anyway.
Does kbuild perhaps have some magic to handle that?

This needs to be solved soon, but I have no idea how.

I also wanna note that I am looking into using quilt for bcm43xx development.
git is not the perfect solution for bcm43xx development. Maybe quilt is.
Who knows... Let's try it.

-- 
Greetings Michael, who would like to have the namespace keyword in C.
