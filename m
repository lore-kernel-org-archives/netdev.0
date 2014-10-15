From: Jason Wang <jasowang@redhat.com>
Subject: Re: [RFC PATCH net-next 6/6] virtio-net: enable tx interrupt only
	for the final skb in the chain
Date: Wed, 15 Oct 2014 18:31:19 +0800
Message-ID: <543E4CF7.1040405@redhat.com>
References: <1413357930-45302-1-git-send-email-jasowang@redhat.com>
	<1413357930-45302-7-git-send-email-jasowang@redhat.com>
	<20141015102251.GE25776@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, davem@davemloft.net
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20141015102251.GE25776@redhat.com>
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

On 10/15/2014 06:22 PM, Michael S. Tsirkin wrote:
> On Wed, Oct 15, 2014 at 03:25:30PM +0800, Jason Wang wrote:
>> With the help of xmit_more and virtqueue_enable_cb_avail(), this patch
>> enable tx interrupt only for the final skb in the chain if
>> needed. This will help to mitigate tx interrupts.
>>
>> Cc: Rusty Russell <rusty@rustcorp.com.au>
>> Cc: Michael S. Tsirkin <mst@redhat.com>
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
> I think you should split xmit_more stuff out.

No much difference but if you prefer I will do this.
