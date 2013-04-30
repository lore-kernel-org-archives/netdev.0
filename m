From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Tue, 30 Apr 2013 04:03:46 -0400 (EDT)
Message-ID: <20130430.040346.1354791082943611347.davem@davemloft.net>
References: <20130426134814.17f27efe88073999dcf634bb@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, kaber@trash.net,
	ajit.khaparde@emulex.com
To: sfr@canb.auug.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130426134814.17f27efe88073999dcf634bb@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Fri, 26 Apr 2013 13:48:14 +1000

> Hi all,
> 
> After merging the net-next tree, today's linux-next build (powerpc
> ppc64_defconfig) failed like this:
> 
> drivers/net/ethernet/emulex/benet/be_main.c: In function 'be_insert_vlan_in_pkt':
> drivers/net/ethernet/emulex/benet/be_main.c:786:3: error: too few arguments to function '__vlan_put_tag'
> include/linux/if_vlan.h:220:31: note: declared here
> drivers/net/ethernet/emulex/benet/be_main.c:796:3: error: too few arguments to function '__vlan_put_tag'
> include/linux/if_vlan.h:220:31: note: declared here
> 
> Caused by comt interaction of commit 86a9bad3ab6b ("net: vlan: add
> protocol argument to packet tagging functions") from the net-next tree
> and commit bc0c3405abbb ("be2net: fix a Tx stall bug caused by a specific
> ipv6 packet") from the net tree.
> 
> I applied the following merge fix patch:

I fixed this in the merge commit when I merged net into net-next, thanks!
