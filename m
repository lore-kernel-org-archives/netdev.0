From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 2/5] net/9p: Improve 19 size determinations
Date: Tue, 15 Aug 2017 15:21:53 +0100
Message-ID: <20170815142152.GA5426@ZenIV.linux.org.uk>
References: <22a44d7c-cdb9-e206-4b2c-56e38cbf0de1@users.sourceforge.net>
 <f9eeedc4-5d3d-6622-79f0-11174ea81c49@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: v9fs-developer@lists.sourceforge.net, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Eric Van Hensbergen <ericvh@gmail.com>,
        Latchesar Ionkov <lucho@ionkov.net>,
        Ron Minnich <rminnich@sandia.gov>,
        LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <f9eeedc4-5d3d-6622-79f0-11174ea81c49@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 15, 2017 at 02:00:06PM +0200, SF Markus Elfring wrote:
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Tue, 15 Aug 2017 09:36:20 +0200
> 
> Replace the specification of data structures by variable references
> as the parameter for the operator "sizeof" to make the corresponding size
> determination a bit safer according to the Linux coding style convention.

Garbage.  This makes it so much harder to find where the objects of given
type are created.  It's _not_ safer and any patches of that sort around
VFS will be shitcanned.  What to do with net/9p patches is up to net/9p
maintainers, but I would strongly recommend the same treatment.
