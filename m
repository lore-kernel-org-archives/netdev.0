From: Florian Weimer <fw@deneb.enyo.de>
Subject: Re: Route cache performance under stress
Date: Sun, 08 Jun 2003 15:10:25 +0200
Sender: linux-net-owner@vger.kernel.org
Message-ID: <874r30r9z2.fsf@deneb.enyo.de>
References: <87wuge59w2.fsf@deneb.enyo.de>
	<20030526.233211.54217447.davem@redhat.com>
	<87he70re62.fsf@deneb.enyo.de>
	<20030608.050500.28795668.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030608.050500.28795668.davem@redhat.com> (David S. Miller's
 message of "Sun, 08 Jun 2003 05:05:00 -0700 (PDT)")
List-Id: netdev.vger.kernel.org

"David S. Miller" <davem@redhat.com> writes:

> Although, I hope it's not "too similar" to what CEF does because
> undoubtedly Cisco has a bazillion patents in this area.

Most things in this area are patented, and the patents are extremely
fuzzy (e.g. policy-based routing with hierarchical sequence of
decisions has been patented countless times). 8-(

> This is actually an argument for coming up with out own algorithms
> without any knowledge of what CEF does or might do. :(

The branchless variant is not described in the IOS book, and I can't
tell if Cisco routers use it.  If this idea is really novel, we are in
pretty good shape because we no longer use trees, tries or whatever,
but a DFA. 8-)

Further parameters which could be tweaked is the kind of adjacency
information (where to store the L2 information, whether to include the
prefix length in the adjacency record etc.).
