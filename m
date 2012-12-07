From: Asias He <asias@redhat.com>
Subject: Re: [PATCH] vhost-blk: Add vhost-blk support v6
Date: Fri, 07 Dec 2012 15:05:24 +0800
Message-ID: <50C19534.2000705@redhat.com>
References: <1354412033-32372-1-git-send-email-asias@redhat.com>
	<20121206130004.GA21312@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jens Axboe <axboe@kernel.dk>, kvm@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Christoph Hellwig <hch@infradead.org>,
	"David S. Miller" <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20121206130004.GA21312@redhat.com>
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

On 12/06/2012 09:00 PM, Michael S. Tsirkin wrote:
> On Sun, Dec 02, 2012 at 09:33:53AM +0800, Asias He wrote:
>> diff --git a/drivers/vhost/Kconfig.blk b/drivers/vhost/Kconfig.blk
>> new file mode 100644
>> index 0000000..ff8ab76
>> --- /dev/null
>> +++ b/drivers/vhost/Kconfig.blk
>> @@ -0,0 +1,10 @@
>> +config VHOST_BLK
>> +	tristate "Host kernel accelerator for virtio blk (EXPERIMENTAL)"
>> +	depends on BLOCK &&  EXPERIMENTAL && m
> 
> 
> should depend on eventfd as well.

Okay, added.

-- 
Asias
