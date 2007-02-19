From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: Re: Kernel bug in bcm43xx-d80211
Date: Mon, 19 Feb 2007 17:30:47 -0500
Message-ID: <1171924247.2257.31.camel@dv>
References: <358127.50930.qm@web50203.mail.yahoo.com>
	 <1171923128.15489.35.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Alex Davis <alex14641-/E1597aS9LQAvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1171923128.15489.35.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-02-19 at 23:12 +0100, Johannes Berg wrote:
> On Mon, 2007-02-19 at 13:48 -0800, Alex Davis wrote:
> > I go the following Oops with the latest wireless-dev git when starting wpa_supplicant:
> > 
> > Feb 19 16:17:42 boss kernel: [  377.359573] BUG: unable to handle kernel NULL pointer dereference
> > at virtual address 00000002
> 
> Probably caused by my recent changes that accidentally broke d80211
> pretty much completely. Patches are on the linux-wireless mailing list.

Johannes, would it be possible to commit patches faster, please?  Now
that I told Michael about git-update-server-info, his changes are
downloadable as soon as he makes a commit.  wireless-dev.git, on the
other hand, is a mess and has been for some time (since Friday, I
believe).

It is a problem for projects like DadWifi that recommend to use the top
of wireless-dev.git.  Yes, I know, breakage is unavoidable to a certain
degree, but it shouldn't come to the situation when the patches are
known, nobody objects, yet the repository stays broken and all newcomers
have to be told about the problem.

That's not to offend you or anyone.  It's just something that would help
a lot.

-- 
Regards,
Pavel Roskin
