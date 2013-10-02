From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3 net-next] fib_trie: avoid a redundant bit judgement
 in inflate
Date: Wed, 02 Oct 2013 16:37:51 -0400 (EDT)
Message-ID: <20131002.163751.1094931323876276388.davem@davemloft.net>
References: <1380584709-5877-1-git-send-email-baker.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: baker.kernel@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1380584709-5877-1-git-send-email-baker.kernel@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: baker.kernel@gmail.com
Date: Tue,  1 Oct 2013 07:45:09 +0800

> From: "baker.zhang" <baker.kernel@gmail.com>
> 
> Because 'node' is the i'st child of 'oldnode',
> thus, here 'i' equals
> tkey_extract_bits(node->key, oldtnode->pos, oldtnode->bits)
> 
> we just get 1 more bit,
> and need not care the detail value of this bits.
> 
> I apologize for the mistake.
> 
> I generated the patch on a branch version,
> and did not notice the put_child has been changed.
> 
> I have redone the test on HEAD version with my patch.

Applied, thanks for testing things so thoroughly.
