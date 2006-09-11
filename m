From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH] fix for system lockups in 2.6.18-rcX caused by bcm43xx
Date: Mon, 11 Sep 2006 15:28:52 -0400
Message-ID: <20060911192846.GB19326@tuxdriver.com>
References: <45021D4A.6040805@lwfinger.net>
	<20060909152305.GA27080@tuxdriver.com>
	<4502E62B.5060601@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Stefano Brivio <st3-sGOZH3hwPm2sTnJN9+BGXg@public.gmane.org>,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>,
	Broadcom Linux <bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4502E62B.5060601-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
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

On Sat, Sep 09, 2006 at 11:04:59AM -0500, Larry Finger wrote:
> John W. Linville wrote:
> >On Fri, Sep 08, 2006 at 08:47:54PM -0500, Larry Finger wrote:
> >
> >>PLease send this upstream for inclusion in 2.6.18, if possible. This 
> >>patch will not work for
> >>wireless-2.6. That patch will be sent to you soon.
> >
> >Are you saying this will break the upstream branch of wireless-2.6?
> >I'm not too excited about that.  Under the normal process, that would
> >mean 2.6.19 would be broken until we get the next patch.
> >
> >When will the patch for the upstream branch be available?  Can you make
> >that patch based on this one (i.e. apply this one before generating
> >the next patch)?
> 
> It will not break wireless-2.6. I sent the equivalent of this patch for 
> wireless-2.6 to you under the subject "[PATCH] bcm43xx-softmac: Init, 
> shutdown and restart fixes" on August 21, just after I took over 
> maintenance of bcm43xx-softmac. If this is not currently queued, please let 
> me know.

OK, I see now.  The patch won't apply to the upstream branch at all
due to the open-coded locking patch applied previously.

The problem now is that if I send this up for 2.6.18 then it creates
some messiness in the git repositories.  Plus, it still might not
make 2.6.18 because it is already very late.

I think I will have to ask you to hold-on to this until Linus
officially releases 2.6.18.  Then you can/should send this patch to
the stable team (stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org) for inclusion in 2.6.18.1
or later.

> I would like to get a listing of patches for bcm43xx-softmac that are 
> queued but not yet applied, and the order in which they will be applied. I 
> want to make sure nothing has fallen through the cracks, and that the 
> patches will apply cleanly.

I have these:

Date	Title
----	-----
8/21	bcm43xx-softmac: Init, shutdown and restart fixes
8/30	WE-21 for bcm43xx
9/3	remove dead code from bcm43xx-softmac
9/4	add firmware version printout
9/6	ucode debug status via sysfs
9/7	remove dead code in bcm43xx_sysfs.c

The first has not been merged because I haven't seen a reply to
Michael's last comments in that thread.  The WE-21 patch has not been
merged because I haven't merged the WE-21 stuff yet.  The others are
all from last week, which I just haven't processed yet.

Will you be responding to Michael's comments on the "Init, shutdown
and restart fixes" patch?

Thanks,

John

P.S.  For some reason, I often have trouble applying your patches.
I'm not sure what process you are using to generate your patches, but
please make sure that your patches can be successfully applied when
your email is fed to 'git applymbox'.  If you use git, the output of
'git format-patch' should be usable.

Also, if you could just use "---" instead of a long line of "======",
I think I would have to do less manual processing...thanks!
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
