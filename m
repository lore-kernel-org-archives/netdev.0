From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2 v4] s2io: add PCI error recovery support
Date: Mon, 21 May 2007 15:49:58 -0700
Message-ID: <20070521154958.c5bc1fcb.akpm@linux-foundation.org>
References: <20070521185853.GD5921@austin.ibm.com>
	<20070521144847.439103c4.akpm@linux-foundation.org>
	<20070521222357.GG5921@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Ramkrishna Vepa <Ramkrishna.Vepa@neterion.com>,
	Sivakumar Subramani <sivakumar.subramani@neterion.com>,
	Sreenivasa Honnur <sreenivasa.honnur@neterion.com>,
	Rastapur Santosh <santosh.rastapur@neterion.com>,
	Wen Xiong <wenxiong@us.ibm.com>,
	linux-pci@atrey.karlin.mff.cuni.cz, netdev@vger.kernel.org
To: linas@austin.ibm.com (Linas Vepstas)
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:57720 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756073AbXEUW4A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 May 2007 18:56:00 -0400
In-Reply-To: <20070521222357.GG5921@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 21 May 2007 17:23:57 -0500
linas@austin.ibm.com (Linas Vepstas) wrote:

> On Mon, May 21, 2007 at 02:48:47PM -0700, Andrew Morton wrote:
> > On Mon, 21 May 2007 13:58:53 -0500
> > linas@austin.ibm.com (Linas Vepstas) wrote:
> > > This patch adds PCI error recovery support to the 
> > 
> > This is already in Jeff's development tree.  Your new patch neither
> > applies nor unapplies, so if you've changed it, Jeff is now sitting
> > on an old version.  I assume he'd like an incremental update patch.
> 
> Ahh ! 
> 
> I assume I have to git-pull
>   /pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git
> or something like that. Will try that now.

git://git.kernel.org/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git#ALL
should suit.

> The part that confuses me is that I'd gotten a message from Jeff
> back in March (well before 2.6.21 came out), saying it was in his
> development tree; yet, the patch its not in 2.6.22-rc; Torvalds
> hasn't yet pulled from it?

Look like it went into Jeff's tree on May 14.  2.6.22-rc1 was released on
May 13, so the patch missed the merge window.
