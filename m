From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH] bcm43xx-d80211: measure the channel change time
Date: Fri, 19 May 2006 14:02:00 -0400
Message-ID: <20060519180155.GC30177@tuxdriver.com>
References: <200605032105.53694.mb@bu3sch.de> <20060504111140.050c3e2f@griffin.suse.cz> <1146745340.1137.26.camel@localhost> <20060504143355.7bbfef35@griffin.suse.cz> <1146746216.1137.33.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Benc <jbenc-AlSwsSmVLrQ@public.gmane.org>, Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>,
   netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-admin-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1146746216.1137.33.camel@localhost>
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

On Thu, May 04, 2006 at 02:36:56PM +0200, Johannes Berg wrote:
> On Thu, 2006-05-04 at 14:33 +0200, Jiri Benc wrote:
> 
> > TSF is set to a value sent by an AP. Is there anything that prevents
> > that AP to send you e.g. 0xfffffffffffff0?
> 
> Ah, good point, I didn't think of stupid APs. Yeah, it should handle it
> I guess.

I'm going to apply this patch as it stands.  Please follow-up with
a patch to handle the TSF overflow.

Thanks,

John
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
