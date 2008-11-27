From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2/6] fs: Introduce special dentries for pipes, socket,
	anon fd
Date: Thu, 27 Nov 2008 05:04:26 -0500
Message-ID: <20081127100426.GA18022@infradead.org>
References: <492DDC5C.1050602@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	linux kernel <linux-kernel@vger.kernel.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Mike Galbraith <efault@gmx.de>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Christoph Lameter <cl@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753961AbYK0KEq@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <492DDC5C.1050602@cosmosbay.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The dentry and indoe patches will take some time to review propery as
they touch hairy code.  For your next respin I'd suggest putting them to
the end of the series so we could eventually merge the other bits
earlier.  Also please changed the special naming to something meanfull,
and please try to have just one single flag in the superblock
controlling all the behvaiour for the can't be unmouynted special case.
