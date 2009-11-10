From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: linux-next: manual merge of the net tree with the i2c tree
Date: Tue, 10 Nov 2009 13:22:58 +0000
Message-ID: <1257859379.2834.2.camel@achroite.uk.solarflarecom.com>
References: <20091026133757.7cf87e49.sfr@canb.auug.org.au>
	 <20091110124231.66141a0f@hyperion.delvare>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mika Kuoppala <mika.kuoppala@nokia.com>
To: Jean Delvare <khali@linux-fr.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20091110124231.66141a0f@hyperion.delvare>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2009-11-10 at 12:42 +0100, Jean Delvare wrote:
> Hi Stephen, Ben,
> 
> On Mon, 26 Oct 2009 13:37:57 +1100, Stephen Rothwell wrote:
> > Today's linux-next merge of the net tree got a conflict in
> > drivers/net/sfc/sfe4001.c between commit
> > 3f7c0648f727a6d5baf6117653e4001dc877b90b ("i2c: Prevent priority
> > inversion on top of bus lock") from the i2c tree and commit
> > c9597d4f89565b6562bd3026adbe6eac6c317f47 ("sfc: Merge sfe4001.c into
> > falcon_boards.c") from the net tree.
> > 
> > I have applied the following merge fixup patch (after removing
> > drivers/net/sfc/sfe4001.c) and can carry it as necessary.
> 
> I've merged the new API to get and release the i2c_adapter mutex:
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=afa08974fe80c198b8650f73ed8ab59135ca10d0

Thanks, Jean.

> Ben, you can adjust your own patches to make use of this API instead of
> accessing the i2c_adapter mutex directly. That way, you are no longer
> dependent of implementation changes, and this should solve the conflict.
> 
> Stephen, you can then drop your fixup patch.

I don't think so, since the conflict resulted from joining two files
including sfe4001.c in net-next-2.6.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
