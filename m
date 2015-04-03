From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [RFC PATCH 3/5] Rename support library for geneve
Date: Fri, 3 Apr 2015 10:40:32 -0400
Message-ID: <20150403144032.GB31348@tuxdriver.com>
References: <1428002227-11636-1-git-send-email-linville@tuxdriver.com>
 <1428002227-11636-4-git-send-email-linville@tuxdriver.com>
 <CAHA+R7Op9inHY=CvyyqgK4v7=xxntAPmZBzBYg27hxcKFF7H6A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@nicira.com>, Andy Zhou <azhou@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:59770 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752698AbbDCOpS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 10:45:18 -0400
Content-Disposition: inline
In-Reply-To: <CAHA+R7Op9inHY=CvyyqgK4v7=xxntAPmZBzBYg27hxcKFF7H6A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 02, 2015 at 05:05:26PM -0700, Cong Wang wrote:
> On Thu, Apr 2, 2015 at 12:17 PM, John W. Linville
> <linville@tuxdriver.com> wrote:
> > net/ipv4/geneve.c -> net/ipv4/libgeneve.c
> >
> > This name better reflects the purpose of the module.
> 
> There are several files under net/ipv4/ used as a library,
> there is no reason to just highlight this single one. So
> this change is not necessary at all.

If you really want to bikeshed this, than the necessity of the name
change depends upon your perspective...  The thing is that I want
the netdev module to be named "geneve.ko".  This mirrors the naming
convention used by the vxlan module, and it just makes sense to me.

Having two modules with the same name seems to confuse modprobe
and company such that module autoloading stops working correctly.
The details escape me, but feel free to apply this series without this
one patch and try it for yourself.  The net effect is that either this
name has to change, or I need a different name (geneve-netdev.ko?) for
the netdev module.  A third option might be to combine this module
with the netdev code, but I kinda like the structure of keeping this
shared code in its own module.

Do you object to the name itself?  Or to having a file with a name like
that under the net/ipv4 directory?  Would you find genevelib.c any
less objectionable than libgeneve.c?  Can you suggest a better place
to keep the shared geneve code?  Or a name change that you like better?

Honestly, this name change seems like the simplest and least awkward
choice to me.  But, I am open to suggestions...

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
