From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Broadcom 43xx first results
Date: Mon, 5 Dec 2005 19:10:08 +0000
Message-ID: <20051205191008.GA28433@infradead.org>
References: <E1Eiyw4-0003Ab-FW@www1.emo.freenet-rz.de> <20051205190038.04b7b7c1@griffin.suse.cz> <4394892D.2090100@gentoo.org> <20051205195543.5a2e2a8d@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joseph Jezak <josejx@gentoo.org>, mbuesch@freenet.de,
	linux-kernel@vger.kernel.org, bcm43xx-dev@lists.berlios.de,
	NetDev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932515AbVLETKQ@vger.kernel.org>
To: Jiri Benc <jbenc@suse.cz>
Content-Disposition: inline
In-Reply-To: <20051205195543.5a2e2a8d@griffin.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 05, 2005 at 07:55:43PM +0100, Jiri Benc wrote:
> Unfortunately, the only long-term solution is to rewrite completely the
> current in-kernel ieee80211 code (I would not call it a "stack") or
> replace it with something another. The current code was written for
> Intel devices and it doesn't support anything else - so every developer
> of a wifi driver tries to implement his own "softmac" now. I cannot see
> how this can move as forward and I think we can agree this is not the
> way to go.

Please stop beeing a freaking jackass.  There are various projects using
the current code.  It's not perfect but people are working on it.  And Joseph &
friends are writing a module to support softmac cards in that framework,
which is one of the most urgently needed things right now, because all the
existing softmac frameworks don't work with that code.

And please stop your stupid devicespace advertisements.  If you think the
code is so useful why don't you send patches to integrate it with the
currently existing wireless code (after cleaning up the horrible mess
it is currently)?
