From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 2.6] iptables CLUSTERIP target
Date: Thu, 21 Oct 2004 08:18:37 +0900 (JST)
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <20041021.081837.99226422.yoshfuji@linux-ipv6.org>
References: <20041020223828.GP19899@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com,
	netfilter-devel@lists.netfilter.org, lmb@suse.de
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: laforge@netfilter.org
In-Reply-To: <20041020223828.GP19899@sunbeam.de.gnumonks.org>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

In article <20041020223828.GP19899@sunbeam.de.gnumonks.org> (at Thu, 21 Oct 2004 00:38:28 +0200), Harald Welte <laforge@netfilter.org> says:

> Apart from the usual netfilter-specific file additions and
> Kconfig/Makefile patches, this needs to export proc_file_operations in
> order to get the reference counting of certain data objects right.  I
> hope this change is acceptable.

Please use seq_file instead.  Thanks.

--yoshfuji
