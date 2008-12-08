From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: CIFS regression in 2.6.27.8
Date: Mon, 8 Dec 2008 21:12:48 +0100
Message-ID: <200812082112.49468.rjw@sisk.pl>
References: <20900699.post@talk.nabble.com> <84144f020812081128p6d1e2a55v69996a360e7f0e8f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Dennis Hardy" <dhardy@sogetthis.com>,
	linux-kernel@vger.kernel.org, layton@redhat.com,
	"Steven French" <sfrench@us.ibm.com>, "Greg KH" <gregkh@suse.de>,
	netdev@vger.kernel.org, Holger Hoffstaette <holger@wizards.de>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>
To: "Pekka Enberg" <penberg@cs.helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:41523 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751742AbYLHUNd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Dec 2008 15:13:33 -0500
In-Reply-To: <84144f020812081128p6d1e2a55v69996a360e7f0e8f@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, 8 of December 2008, Pekka Enberg wrote:
> Hi Dennis,
> 
> On Mon, Dec 8, 2008 at 8:18 PM, Dennis Hardy <dhardy@sogetthis.com> wrote:
> > I just mounted a network drive (Windows Server) via CIFS under 2.6.27.8, and
> > the sizes reported by "df" are completely incorrect:
> >
> >  root@exodus:~# df -h /mnt/fsv1
> >  Filesystem            Size  Used Avail Use% Mounted on
> >  //fsv1/Users          446G -222G  667G   -  /mnt/fsv1
> >  root@exodus:~# df /mnt/fsv1
> >  Filesystem           1K-blocks      Used Available Use% Mounted on
> >  //fsv1/Users         467403140 -231816588 699219728   -  /mnt/fsv1
> >  root@exodus:~# mount | grep fsv1
> >  //fsv1/Users on /mnt/fsv1 type cifs (rw,mand)
> >  root@exodus:~#
> >
> > Does anyone else see this sort of behavior with 2.6.27.8?  This worked fine
> > in 2.6.27.6 (we skipped 2.6.27.7)...
> >
> > Ideas?
> 
> Well, lets cc the relevant people so your report isn't lost in the noise.

FWIW, it seems to be related to this one: http://lkml.org/lkml/2008/12/8/7

Thanks,
Rafael
