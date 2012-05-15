From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [V2 PATCH 1/9] macvtap: zerocopy: fix offset calculation when
 building skb
Date: Tue, 15 May 2012 10:17:46 -0700
Message-ID: <1337102266.8220.6.camel@oc3660625478.ibm.com>
References: <20120502033901.11782.13157.stgit@amd-6168-8-1.englab.nay.redhat.com>
	 <20120502034130.11782.25906.stgit@amd-6168-8-1.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ebiederm@xmission.com,
	davem@davemloft.net
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120502034130.11782.25906.stgit@amd-6168-8-1.englab.nay.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-05-02 at 11:41 +0800, Jason Wang wrote:
> This patch fixes the offset calculation when building skb:
> 
> - offset1 were used as skb data offset not vector offset
> - reset offset to zero only when we advance to next vector

I tested the original code in all scenario, it worked well.

However this patch makes the code more clear.

Thanks
Shirley
