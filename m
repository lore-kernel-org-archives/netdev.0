From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net V2] virtio-net: drop NETIF_F_FRAGLIST
Date: Thu, 06 Aug 2015 15:49:10 -0700 (PDT)
Message-ID: <20150806.154910.1261240005857312043.davem@davemloft.net>
References: <1438742044-31064-1-git-send-email-jasowang@redhat.com>
	<20150806161042-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sergei.shtylyov@cogentembedded.com,
	virtualization@lists.linux-foundation.org
To: mst@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20150806161042-mutt-send-email-mst@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Thu, 6 Aug 2015 16:13:11 +0300

> On Wed, Aug 05, 2015 at 10:34:04AM +0800, Jason Wang wrote:
>> virtio declares support for NETIF_F_FRAGLIST, but assumes
>> that there are at most MAX_SKB_FRAGS + 2 fragments which isn't
>> always true with a fraglist.
>> 
>> A longer fraglist in the skb will make the call to skb_to_sgvec overflow
>> the sg array, leading to memory corruption.
>> 
>> Drop NETIF_F_FRAGLIST so we only get what we can handle.
>> 
>> Cc: Michael S. Tsirkin <mst@redhat.com>
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
> 
> I noticed only now that this didn't Cc Dave, so of course it's
> not applied.

CC:'ing me isn't the requirement. CC:'ing netdev is, which he
did.  If you check patchwork, it's there in the queue.

I'm just behind and heavily backlogged because I've been working
on other things.
