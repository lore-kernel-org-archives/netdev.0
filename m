From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next V2 0/3] rx busy polling support for virtio-net
Date: Thu, 17 Jul 2014 14:59:26 +0800
Message-ID: <53C7744E.60806@redhat.com>
References: <1405491707-22706-1-git-send-email-jasowang@redhat.com>
	<20140716.232116.802194909968085691.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, mst@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20140716.232116.802194909968085691.davem@davemloft.net>
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

On 07/17/2014 02:21 PM, David Miller wrote:
> From: Jason Wang <jasowang@redhat.com>
> Date: Wed, 16 Jul 2014 14:21:44 +0800
>
>> Hi all:
>>
>> This series introduces the support for rx busy polling support. This
>> was useful for reduing the latency for a kvm guest. Patch 1-2
>> introduces helpers which is used for rx busy polling. Patch 3
>> implement the main function.
>>
>> Test was done between a kvm guest and an external host. Two hosts were
>> connected through 40gb mlx4 cards. With both busy_poll and busy_read are
>> set to 50 in guest, 1 byte netperf tcp_rr shows 116% improvement:
>> transaction rate was increased from 9151.94 to 19787.37.
>>
>> Changes from V1:
>> - split the patch info smaller ones
>> - add more details about test setup/configuration
>>
>> Please review.
> Looks like you can make some minor adjustments based upon review, and
> anyways I'd like to wait for Michael to get back and review a change
> of this nature.
>
> Thanks.

Ok, I will wait for Michael's comments and then post V3.

Thanks
