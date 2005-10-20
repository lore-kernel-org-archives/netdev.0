From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [patch 2.6.14-rc4] b44: alternate allocation option for DMA descriptors
Date: Thu, 20 Oct 2005 10:33:29 -0400
Message-ID: <20051020143326.GB25010@tuxdriver.com>
References: <10182005213059.12243@bilbo.tuxdriver.com> <1129792626.7620.248.camel@gaston>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jgarzik@pobox.com, pp@ee.oulu.fi
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932190AbVJTOdv@vger.kernel.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Content-Disposition: inline
In-Reply-To: <1129792626.7620.248.camel@gaston>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 20, 2005 at 05:17:05PM +1000, Benjamin Herrenschmidt wrote:

> So basically, what you are doing is: if allocation fails, you try to get
> memory using GFP_KERNEL. If it happens to be in the low 2Gb of memory,
> use it, if not, drop it.
> 
> Did I get that right ?

Yes, that is basically correct.  I wish I had something more clever
than that...suggestions welcome...

John
-- 
John W. Linville
linville@tuxdriver.com
