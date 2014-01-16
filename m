From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next RFC] virtio-net: drop rq->max and rq->num
Date: Thu, 16 Jan 2014 12:24:51 +0800
Message-ID: <52D75F13.2060504@redhat.com>
References: <1388134685-30691-1-git-send-email-jasowang@redhat.com>	<87mwixx670.fsf@rustcorp.com.au>	<87zjmwvlzl.fsf@rustcorp.com.au>
	<20140115.164649.533508366980529205.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, mst@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20140115.164649.533508366980529205.davem@davemloft.net>
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

On 01/16/2014 08:46 AM, David Miller wrote:
> From: Rusty Russell<rusty@rustcorp.com.au>
> Date: Thu, 16 Jan 2014 10:25:26 +1030
>
>> Rusty Russell<rusty@rustcorp.com.au>  writes:
>>> Jason Wang<jasowang@redhat.com>  writes:
>>>> It looks like there's no need for those two fields:
>>>>
>>>> - Unless there's a failure for the first refill try, rq->max should be always
>>>>    equal to the vring size.
>>>> - rq->num is only used to determine the condition that we need to do the refill,
>>>>    we could check vq->num_free instead.
>>>> - rq->num was required to be increased or decreased explicitly after each
>>>>    get/put which results a bad API.
>>>>
>>>> So this patch removes them both to make the code simpler.
>>> Nice.  These fields date from when the vq struct was opaque.
>>>
>>> Applied,
>>> Rusty.
>> Oops, this doesn't require any core virtio changes, so it's for DaveM:
>>
>> Acked-by: Rusty Russell<rusty@rustcorp.com.au>
> Jason please repost this with Rusty's ACK, thanks.

Sure, will repost.
