From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH dscape] d80211: Switch d80211.h to IEEE80211_ style names
Date: Sat, 5 Aug 2006 19:47:43 +0200
Message-ID: <200608051947.44280.mb@bu3sch.de>
References: <200607270037.22384.flamingice@sourmilk.net> <20060805114650.GC21135@infradead.org> <200608051930.55792.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:28346
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1422660AbWHERsV
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Aug 2006 13:48:21 -0400
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <200608051930.55792.mb@bu3sch.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 05 August 2006 19:30, Michael Buesch wrote:
> On Saturday 05 August 2006 13:46, Christoph Hellwig wrote:
> > On Tue, Aug 01, 2006 at 08:21:49AM -0400, John W. Linville wrote:
> > > I don't anticipate the d80211 naming conventions to ever make it out
> > > of wireless-dev.  By the time we are ready to push that stuff upstream,
> > > we will have cleaned-up our messes.
> > 
> > Yes, absolutely.
> > 
> > > This does raise the question: Should we start taking patches to
> > > wireless-dev that migrate the current (i.e. ieee80211/softmac) stack
> > > out of the kernel?  This would include (re-)moving the current stack
> > > code, pointing non-migrated drivers (ipw2[12]00, zd1211rw) at the old
> > > code, moving drivers out of drivers/net/wireless/d80211 up a level,
> > > removing the softmac-based version of the bcm43xx driver, etc.
> 
> Yes, I personally would like to see that happen now.

I forgot to say why ;)

It's getting a major pain to support two up-to-date bcm43xx drivers.
It's getting nontrivial to port drivers over from bcm43xx-softmac
to bcm43xx-d80211; even with tools like quilt and wiggle.

What I'd like to see is: After 2.6.18 got out, we freeze bcm43xx-softmac
and only allow small bugfixes to it. All development work would go
into the d80211 branch.
That saves me a _lot_ of time and pain.

-- 
Greetings Michael.
