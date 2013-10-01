From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [net-next PATCH V2] virtio-net: switch to use XPS to choose txq
Date: Tue, 01 Oct 2013 11:24:08 +0930
Message-ID: <87eh8521tr.fsf@rustcorp.com.au>
References: <1380526637-35524-1-git-send-email-jasowang@redhat.com>
	<20130930090402.GB20291@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>, Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20130930090402.GB20291@redhat.com>
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

"Michael S. Tsirkin" <mst@redhat.com> writes:
> On Mon, Sep 30, 2013 at 03:37:17PM +0800, Jason Wang wrote:
>> We used to use a percpu structure vq_index to record the cpu to queue
>> mapping, this is suboptimal since it duplicates the work of XPS and
>> loses all other XPS functionality such as allowing use to configure
>> their own transmission steering strategy.
>> 
>> So this patch switches to use XPS and suggest a default mapping when
>> the number of cpus is equal to the number of queues. With XPS support,
>> there's no need for keeping per-cpu vq_index and .ndo_select_queue(),
>> so they were removed also.
>> 
>> Cc: Rusty Russell <rusty@rustcorp.com.au>
>> Cc: Michael S. Tsirkin <mst@redhat.com>
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
>
> Acked-by: Michael S. Tsirkin <mst@redhat.com>

Acked-by: Rusty Russell <rusty@rustcorp.com.au>

Dave, please apply.

Cheers,
Rusty.
