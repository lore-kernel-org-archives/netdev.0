From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] virtio-net: fix a race on 32bit arches
Date: Sun, 10 Jun 2012 20:23:41 -0700 (PDT)
Message-ID: <20120610.202341.2146277133562218686.davem@davemloft.net>
References: <1338971724.2760.3913.camel@edumazet-glaptop>
	<20120610102512.GB6793@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, shemminger@vyatta.com
To: mst@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20120610102512.GB6793@redhat.com>
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
Date: Sun, 10 Jun 2012 13:25:12 +0300

> On Wed, Jun 06, 2012 at 10:35:24AM +0200, Eric Dumazet wrote:
>> From: Eric Dumazet <edumazet@google.com>
>> 
>> commit 3fa2a1df909 (virtio-net: per cpu 64 bit stats (v2)) added a race
>> on 32bit arches.
>> 
>> We must use separate syncp for rx and tx path as they can be run at the
>> same time on different cpus. Thus one sequence increment can be lost and
>> readers spin forever.
>> 
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>> Cc: Stephen Hemminger <shemminger@vyatta.com>
>> Cc: Michael S. Tsirkin <mst@redhat.com>
>> Cc: Jason Wang <jasowang@redhat.com>
> 
> I'm still thinking about moving tx to take a xmit lock long term,
> meanwhile this fix appears appropriate for 3.5.
> 
> Acked-by: Michael S. Tsirkin <mst@redhat.com>
> 
> Dave, can you pick this up pls?

Done, thanks.
