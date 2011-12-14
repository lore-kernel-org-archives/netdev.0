From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the net-next tree with the net tree
Date: Wed, 14 Dec 2011 13:36:44 -0500 (EST)
Message-ID: <20111214.133644.834042724012633409.davem@davemloft.net>
References: <20111214132558.d9ffe5dfb2f09089cec4a21f@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, ordex@autistici.org
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20111214132558.d9ffe5dfb2f09089cec4a21f@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 14 Dec 2011 13:25:58 +1100

> Hi all,
> 
> Today's linux-next merge of the net-next tree got conflicts in
> net/batman-adv/translation-table.c between commits 03fc3070457d
> ("batman-adv: in case of roaming mark the client with TT_CLIENT_ROAM")
> and 797399b415b7 ("batman-adv: delete global entry in case of roaming")
> from the net tree and commit 48100bac89a6 ("batman-adv: create a common
> substructure for tt_global/local_entry") from the net-next tree.
> 
> I fixed it up (I think - see below) and can carry the fix as necessary.

Thanks, we expected this, I'll take care of it next time I merge
over the net tree.
