From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] openvswitch: allocate nr_node_ids flow_stats
 instead of num_possible_nodes
Date: Tue, 21 Jul 2015 22:26:48 -0700 (PDT)
Message-ID: <20150721.222648.171655319967229139.davem@davemloft.net>
References: <20150721162418.GM38815@linux.vnet.ibm.com>
	<1437500193-10255-1-git-send-email-chris.j.arges@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nacc@linux.vnet.ibm.com, pshelar@nicira.com,
	linuxppc-dev@lists.ozlabs.org, benh@kernel.crashing.org,
	linux-numa@vger.kernel.org, netdev@vger.kernel.org,
	dev@openvswitch.org, linux-kernel@vger.kernel.org
To: chris.j.arges@canonical.com
Return-path: <linux-numa-owner@vger.kernel.org>
In-Reply-To: <1437500193-10255-1-git-send-email-chris.j.arges@canonical.com>
Sender: linux-numa-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris J Arges <chris.j.arges@canonical.com>
Date: Tue, 21 Jul 2015 12:36:33 -0500

> Some architectures like POWER can have a NUMA node_possible_map that
> contains sparse entries. This causes memory corruption with openvswitch
> since it allocates flow_cache with a multiple of num_possible_nodes() and
> assumes the node variable returned by for_each_node will index into
> flow->stats[node].
> 
> Use nr_node_ids to allocate a maximal sparse array instead of
> num_possible_nodes().
> 
> The crash was noticed after 3af229f2 was applied as it changed the
> node_possible_map to match node_online_map on boot.
> Fixes: 3af229f2071f5b5cb31664be6109561fbe19c861
> 
> Signed-off-by: Chris J Arges <chris.j.arges@canonical.com>

Applied, thanks.
