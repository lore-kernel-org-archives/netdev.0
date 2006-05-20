From: Andi Kleen <ak@suse.de>
Subject: Re: [git patches] net driver updates
Date: Sun, 21 May 2006 00:15:15 +0200
Message-ID: <200605210015.15847.ak@suse.de>
References: <20060520042856.GA7218@havoc.gtf.org> <Pine.LNX.4.64.0605201035510.10823@g5.osdl.org> <20060520105547.220f2bea.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@osdl.org>, jeff@garzik.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Manfred Spraul <manfred@colorfullife.com>,
	Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:19430 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S932401AbWETWPj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 May 2006 18:15:39 -0400
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20060520105547.220f2bea.akpm@osdl.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 20 May 2006 19:55, Andrew Morton wrote:
> Linus Torvalds <torvalds@osdl.org> wrote:
> >
> > 
> > 
> > On Sat, 20 May 2006, Andrew Morton wrote:
> > > Jeff Garzik <jeff@garzik.org> wrote:
> > > >
> > > > Andrew Morton:
> > > >        revert "forcedeth: fix multi irq issues"
> > > 
> > > Manfred just found the fix for this, so we should no longer need to revert.
> > 
> > Hmm. I already pulled. I guess we can revert the revert and apply 
> > Manfreds fix. Jeff?
> > 
> 
> I can cook up the necessary pieces.

My NF4Pro machine now reliably does

Disconnecting: Bad packet length 3742984839.

when I display a lot of data through ssh.  Apparently it generates some 
corruption that's not caught by the TCP checksum. Would that be fixed by this
change too? 

-Andi

