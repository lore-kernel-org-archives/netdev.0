From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 0/3] netfilter : 3 patches to boost ip_tables performance
Date: Thu, 22 Sep 2005 15:05:04 +0200
Message-ID: <200509221505.05395.ak@suse.de>
References: <43308324.70403@cosmosbay.com> <200509221454.22923.ak@suse.de> <20050922125849.GA27413@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Christoph Lameter <clameter@engr.sgi.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030300AbVIVNFN@vger.kernel.org>
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20050922125849.GA27413@infradead.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 22 September 2005 14:58, Christoph Hellwig wrote:

> Umm, no - adding set_fs/get_fs mess for things like that is not right.

I think it's fine. We're using it for various other interfaces too. In fact
sys_set_mempolicy is already used elsewhere in the kernel too.

-Andi
