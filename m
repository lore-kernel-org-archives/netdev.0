From: James Bottomley <James.Bottomley@HansenPartnership.com>
Subject: Re: Linux 2.6.36-rc7
Date: Fri, 08 Oct 2010 10:05:56 -0500
Message-ID: <1286550357.2985.90.camel@mulgrave.site>
References: <AANLkTi=LsBNU+O2hqZUcM2nYM_ze6qPq3thwSZBMtY_v@mail.gmail.com>
	 <20101007114938.ad3d2c76.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Russell King <rmk@arm.linux.org.uk>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Michal Marek <mmarek@suse.cz>,
	Dmitry Torokhov <dmitry.torokhov@gmail.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101007114938.ad3d2c76.sfr@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-10-07 at 11:49 +1100, Stephen Rothwell wrote:
> Hi Linus,
> 
> On Wed, 6 Oct 2010 14:45:13 -0700 Linus Torvalds <torvalds@linux-foundation.org> wrote:
> >
> > This should be the last -rc, I'm not seeing any reason to keep
> > delaying a real release. There was still more changes to
> > drivers/gpu/drm than I really would have hoped for, but they all look
> > harmless and good. Famous last words.
> 
> I have no idea how critical any of this stuff is, but linux-next contain
> the following in it's "current" trees i.e. stuff that is supposed to go
> into 2.6.36.  These are from the arm-current, scsi-rc-fixes, net-current,
> wireless-current, kbuild-current, input-current and ide-curent trees
> (contacts cc'd).

The SCSI rc-fixes stuff is critical if you run into the bugs, but the
bugs are fairly rare cases for most people.  I'd still like to get them
in, though (and I have another 3 rc fixes candidates going through the
test pipeline).

James
