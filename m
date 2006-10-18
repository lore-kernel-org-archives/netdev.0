From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [take1 0/5] d80211 patches
Date: Wed, 18 Oct 2006 19:23:14 +0200
Message-ID: <200610181923.14370.IvDoorn@gmail.com>
References: <20061017171713.GA13669@devicescape.com> <20061018180131.556fe5bc@griffin.suse.cz> <20061018172009.GA25808@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:61158 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1422723AbWJRRY3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Oct 2006 13:24:29 -0400
Received: by ug-out-1314.google.com with SMTP id o38so235270ugd
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2006 10:24:28 -0700 (PDT)
To: David Kimdon <david.kimdon@devicescape.com>
In-Reply-To: <20061018172009.GA25808@devicescape.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 18 October 2006 19:20, David Kimdon wrote:
> On Wed, Oct 18, 2006 at 06:01:31PM +0200, Jiri Benc wrote:
> > On Tue, 17 Oct 2006 10:17:13 -0700, David Kimdon wrote:
> > > Continue d80211 bitfield removal.  In general, compilers have
> > > difficulty generating efficient code for bitfields.  This patchset
> > > removes all bitfields from include/net/d80211.h.
> > 
> > Thanks for the patches! At first I intended to ask you to split d80211
> > and drivers parts of the patches, but your way is better I think - it
> > doesn't break git-bisect.
> > 
> > John, if you agree with these patches, could you apply them after you
> > pull from my tree?
> 
> hold that thought, I missed updating rt73usb.c and rt2500usb.c.  New
> patchset on its way.

Hi,

That patch was send 2 hours ago by me to this list. :)
"[PATCH] rt2x00: Remove xr_end references"
That patch only fixed rt2500usb and rt73usb, so it can be applied safely
after your patch to fix the rt2x00 PCI drivers. 

Ivo
