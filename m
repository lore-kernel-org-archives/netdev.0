From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next] virtio-net: rx busy polling support
Date: Wed, 16 Jul 2014 10:44:46 +0800
Message-ID: <53C5E71E.7050706@redhat.com>
References: <1405417265-13103-1-git-send-email-jasowang@redhat.com>
	<1405419703.10255.26.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vyasevic@redhat.com>, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1405419703.10255.26.camel@edumazet-glaptop2.roam.corp.google.com>
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

On 07/15/2014 06:21 PM, Eric Dumazet wrote:
> On Tue, 2014-07-15 at 17:41 +0800, Jason Wang wrote:
>> Add basic support for rx busy polling.
>>
>> 1 byte netperf tcp_rr on mlx4 shows 116% improvement: the transaction
>> rate was increased from 9151.94 to 19787.37.
> This is a misleading changelog.
>
> You forgot to describe how you allowed busy polling, as it is not
> 'automatic'
>
> If not, this patch adds two spinlock/unlock pairs in fast path.

Ok.
> Also, it looks like you could split this in smaller patches.
>
> virtnet_napi_disable_all() & virtnet_napi_enable_all() could be added in
> a separate patch for example.

Sure, will split this patch into smaller ones in V2.

Thanks
