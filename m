From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 0/7] AlacrityVM guest drivers Reply-To:
Date: Thu, 6 Aug 2009 18:45:45 +0300
Message-ID: <20090806154543.GA11944@redhat.com>
References: <20090803171030.17268.26962.stgit@dev.haskins.net> <4A7AE150.7040009@redhat.com> <4A7AAB1A0200005A00051BED@sinclair.provo.novell.com> <200908061740.04276.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gregory Haskins <ghaskins@novell.com>, Avi Kivity <avi@redhat.com>,
	alacrityvm-devel@lists.sourceforge.net, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756152AbZHFPrN@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200908061740.04276.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 06, 2009 at 05:40:04PM +0200, Arnd Bergmann wrote:
> 3. The ioq method seems to be the real core of your work that makes
> venet perform better than virtio-net with its virtqueues. I don't see
> any reason to doubt that your claim is correct. My conclusion from
> this would be to add support for ioq to virtio devices, alongside
> virtqueues, but to leave out the extra bus_type and probing method.
> 
> 	Arnd <><

The fact that it's in kernel also likely contributes.

-- 
MST
