From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH dscape] d80211: Switch d80211.h to IEEE80211_ style names
Date: Tue, 1 Aug 2006 19:31:39 +0200
Message-ID: <200608011931.40390.IvDoorn@gmail.com>
References: <200607270037.22384.flamingice@sourmilk.net> <a32f33a40608010725m247304a5vda49207c8f36cf62@mail.gmail.com> <20060801171058.GH29208@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, Christoph Hellwig <hch@infradead.org>,
	Michael Wu <flamingice@sourmilk.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:57518 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1751713AbWHARcE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 13:32:04 -0400
Received: by nf-out-0910.google.com with SMTP id o25so339997nfa
        for <netdev@vger.kernel.org>; Tue, 01 Aug 2006 10:32:01 -0700 (PDT)
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060801171058.GH29208@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 01 August 2006 19:11, John W. Linville wrote:
> On Tue, Aug 01, 2006 at 04:25:05PM +0200, Ivo Van Doorn wrote:
> > Hi,
> > 
> > >> Do you have a plan when you will merge rt2x00 patches so I can apply
> > >> Michael's renaming patch(es) without risk of conflicts?
> > >
> > >Working on it ~now.  I hit a snag in that Ivo's patches seem to rely on
> > >his radio button patch, which I had ignored until now.  I'll probably
> > >pull that in this morning (or figure-out how to not need it) and get
> > >something pushed to wireless-dev sometime today.
> > 
> > Ehm, that should not have happened. The rt2x00 version I had send as patches
> > had the radio button integrated as they had been in wireless-dev already.
> > The patch to convert it to the rfkill driver is one of the patches
> > I'll send later.
> 
> The rfkill stuff seems to be behind a CONFIG_RT2X00_BUTTON define,
> which keys off some driver-specific Kconfig stuff.  They were
> getting turned-on by default w/ 'allmodconfig' and 'allyesconfig'.
> Turning them off in .config lets them compile.

Ah, I have spotted the problem. That was indeed accidently added during the last
patch series. It was part of the patch I was keeping behind.
I'll send the rfkill patch as soon as possible,  that should fix that problem,
in case the rfkill is considered not good enough for inclusion yet, I'll create a
patch to fix this issue correctly.

> In general, I'd prefer not to have Kconfig-settable options that
> don't compile.  But in this case I guess we'll just live with it.
> After all, it is a development tree... :-)

Hehe, true. But I'll do my best to fix this issue soon. :)

Ivo
