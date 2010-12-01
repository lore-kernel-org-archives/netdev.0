From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH v2] add netdev led trigger
Date: Wed, 1 Dec 2010 15:03:30 +0100
Message-ID: <20101201140330.GA7218@basil.fritz.box>
References: <1290998056-8310-1-git-send-email-ecc@cmu.edu>
 <87ipzgl9k8.fsf@basil.nowhere.org>
 <20101201000300.GJ21496@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org,
	linux-doc@vger.kernel.org, Richard Purdie <rpurdie@rpsys.net>,
	Randy Dunlap <rdunlap@xenotime.net>, netdev@vger.kernel.org
Return-path: <linux-doc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101201000300.GJ21496@localhost>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 30, 2010 at 07:03:00PM -0500, Eric Cooper wrote:
> On Mon, Nov 29, 2010 at 11:15:51AM +0100, Andi Kleen wrote:
> > Using the device name as an identifier is not reliable, they may not
> > be unique.
> 
> I'm confused about this -- how else can the user specify the desired network
> interface?

For presenting the user the name is probably still the best, but internally
better use the interface index.
> 
> > rwlocks are deprecated.
> 
> In favor of what?  Should I use a spinlock?

spinlocks or mutexes.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
