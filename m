From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] kill ancient compat cruft from acenic
Date: Wed, 21 Jan 2004 10:47:14 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040121094714.GA20425@lst.de>
References: <20040120141717.GA7549@lst.de> <yq065f566m6.fsf@wildopensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jes Sorensen <jes@wildopensource.com>
Content-Disposition: inline
In-Reply-To: <yq065f566m6.fsf@wildopensource.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jan 21, 2004 at 03:36:17AM -0500, Jes Sorensen wrote:
> >>>>> "Christoph" == Christoph Hellwig <hch@lst.de> writes:
> 
> Christoph> This kills all the cruft needed for supporting anything
> Christoph> other than halfway recent 2.4 and 2.6 kernels.  Should make
> Christoph> converting to the pci hotplug APIs much easier.
> 
> Looks pretty decent, are you sure the MOD_INC_USE_COUNT isn't needed
> for 2.4.18+ ? (no I haven't checked).

Yes, 2.4 already has the owner field in struct net_device.
