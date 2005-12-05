From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Broadcom 43xx first results
Date: Mon, 5 Dec 2005 19:41:46 +0000
Message-ID: <20051205194146.GA29317@infradead.org>
References: <E1Eiyw4-0003Ab-FW@www1.emo.freenet-rz.de> <20051205190038.04b7b7c1@griffin.suse.cz> <4394892D.2090100@gentoo.org> <20051205195543.5a2e2a8d@griffin.suse.cz> <20051205191008.GA28433@infradead.org> <20051205203121.48241a08@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
	Joseph Jezak <josejx@gentoo.org>, mbuesch@freenet.de,
	linux-kernel@vger.kernel.org, bcm43xx-dev@lists.berlios.de,
	NetDev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932535AbVLETlu@vger.kernel.org>
To: Jiri Benc <jbenc@suse.cz>
Content-Disposition: inline
In-Reply-To: <20051205203121.48241a08@griffin.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 05, 2005 at 08:31:21PM +0100, Jiri Benc wrote:
> > And Joseph &
> > friends are writing a module to support softmac cards in that framework,
> > which is one of the most urgently needed things right now, because all the
> > existing softmac frameworks don't work with that code.
> 
> And authors of rtl8180 did it too. And authors of adm8211 too.

None of them made it into the kernel tree.  As soon as we'll have an
acceptable one everyone will have to use and improve it.  I personally
couldn't care less what we start with.

> > And please stop your stupid devicespace advertisements.  If you think the
> > code is so useful why don't you send patches to integrate it with the
> > currently existing wireless code (after cleaning up the horrible mess
> > it is currently)?
> 
> This is what I'm doing last two months. But it's not so easy to clean it
> up and it seems that nobody else is interested. But it has all of the
> features you need (except active scanning) - this is the reason I
> stopped to work on improving current in-kernel 802.11 code and focused
> on Devicescape's code. It is several years beyond the state that current
> code is at now. And it is not an advertisement, it is a fact.

That's because you still don't get how we do development.  The last thing
we want is full-scale rewrites.  Submit patches to fix things based on
whatever you want but do it incremental.  Anything that just moves existing
functionaly out of the place and adds duplicates with more functionality/
cleaner API/<buzzword of the day> is simply not acceptable.
