From: josh@joshtriplett.org
Subject: Re: [PATCH net-next] net: core: Quiet W=1 warnings for unused vars
 and static functions
Date: Mon, 6 Oct 2014 15:27:56 -0700
Message-ID: <20141006222756.GA1497@cloud>
References: <1412632298.2916.42.camel@joe-AO725>
 <20141006.175612.1709169088283433326.davem@davemloft.net>
 <1412633064.2916.46.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, john.fastabend@gmail.com
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1412633064.2916.46.camel@joe-AO725>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 06, 2014 at 03:04:24PM -0700, Joe Perches wrote:
> On Mon, 2014-10-06 at 17:56 -0400, David Miller wrote:
> > From: Joe Perches <joe@perches.com>
> > Date: Mon, 06 Oct 2014 14:51:38 -0700
> > 
> > > Reduce noise when compiling W=1.
> []
> > BTW, this patch reminds me that if people think there are
> > subdirectories where we can turn on things like -Werror in the
> > networking I would be very happy to apply such patches.
> []
> > Things like net/core/ for example should be doable for sure.
> 
> I don't have any significant opposition to -Werror, but
> I think there are real arguments _against_ using -Werror.
> 
> I think the primary one is new compiler versions have a
> tendency to add new warnings for various things that can
> unnecessarily and unpredictably break the build.

-Werror is a bad idea, even on a per-directory basis.  However,
-Werror=specific-warning is a great idea.  We should add that for
high-value warnings that have been entirely eliminated in a directory.

- Josh Triplett
