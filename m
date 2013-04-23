From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the net-next tree with Linus' tree
Date: Mon, 22 Apr 2013 20:42:02 -0400 (EDT)
Message-ID: <20130422.204202.847934226356654222.davem@davemloft.net>
References: <20130422130939.9162d4f519402dcfc4cdbe0c@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, torvalds@linux-foundation.org,
	ebiederm@xmission.com
To: sfr@canb.auug.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130422130939.9162d4f519402dcfc4cdbe0c@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 22 Apr 2013 13:09:39 +1000

> Today's linux-next merge of the net-next tree got a conflict in
> include/net/scm.h between commit 83f1b4ba917d ("net: fix incorrect
> credentials passing") from Linus' tree and commit 6b0ee8c036ec ("scm:
> Stop passing struct cred") from the net-next tree.
> 
> I fixed it up (see below) and can carry the fix as necessary (no action
> is required).  I also applied the following merge fix patch (I am not
> sure if this is correct, but it seems to be consistent):
> 
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Mon, 22 Apr 2013 13:06:10 +1000
> Subject: [PATCH] net: af_unix fix for incorrect credentials passing
> 
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>

I took care of this during the net --> net-next merge, thanks!
