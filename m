From: Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 2.6] WE-22 : prevent information leak on 64 bit
Date: Tue, 17 Apr 2007 14:59:52 -0700
Message-ID: <adaejmi1x2f.fsf@cisco.com>
References: <20070323003116.GC2712@bougret.hpl.hp.com>
	<1175508410.23438.75.camel@johannes.berg>
	<20070417170820.GB22372@bougret.hpl.hp.com>
	<20070417183442.GE8633@tuxdriver.com>
	<20070417211859.GB22897@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070417211859.GB22897-yAE0UhLNZJawPNPzzlOzwdBPR1lH4CV8@public.gmane.org> (Jean Tourrilhes's message of "Tue, 17 Apr 2007 14:19:00 -0700")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

 > > This API was controversial and mostly unwelcome from the start.
 > > It was ridiculed as "ioctls over netlink" at the last kernel summit.
 > 
 > 	Which is complete FUD. In that case, the whole RtNetlink can
 > be classified as "ioctls over netlink".

The problem is that WE over netlink is basically using netlink to
transfer the same binary blobs as the WE ioctls, rather than using
properly structured netlink messages.

 > > One of the objections to having merged the API was that _if_ it were
 > > to gain users then we would have to carry that maintenance burden
 > > ad infinitum.
 > 
 > 	More FUD. It does not add any new commands. The proof is in
 > the pudding, no change was needed in any driver to support it,
 > therefore it could not have added any burden on any compatibility
 > layer.

The point is that if WE over netlink is used by applications, then the
kernel must maintain that ABI (of WE over netlink) forever.

 - R.
