From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: linux-next: manual merge of the net tree with the wireless-current tree
Date: Thu, 26 Nov 2009 08:01:53 -0500
Message-ID: <20091126130153.GA3697@tuxdriver.com>
References: <20091126141055.d8c67798.sfr@canb.auug.org.au> <1259227989.32372.32.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jean Tourrilhes <jt@hpl.hp.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1259227989.32372.32.camel@johannes.local>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 26, 2009 at 10:33:09AM +0100, Johannes Berg wrote:
> On Thu, 2009-11-26 at 14:10 +1100, Stephen Rothwell wrote:
> > Hi all,
> > 
> > Today's linux-next merge of the net tree got a conflict in
> > net/wireless/wext.c between commit
> > 9fed059667d35fca9288460106e92dbb8ba35ea1 ("WE: Fix set events not
> > propagated") from the  tree and commit
> > 3d23e349d807177eaf519d444677cee86b1a04cf ("wext: refactor") from the net
> > tree.
> > 
> > The latter deleted the file that the former modified.  I just ignored the
> > wireless-current change and removed the file (which seems to have been
> > done in the latter change anyway).
> 
> The fix should probably have gone to wext-core.c instead?

Yes.  That's the way I did it in the merge-test branch of wireless-next-2.6.

Thanks,

John
--
John W. Linville
linville@tuxdriver.com
