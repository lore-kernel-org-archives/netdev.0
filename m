From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH 2/2] vhost/scsi: Delete error messages for failed memory
	allocations in five functions
Date: Mon, 22 May 2017 15:38:33 +0300
Message-ID: <20170522123833.asx2biaw4xaz4qpv@mwanda>
References: <bafa65e4-08fe-efdb-d836-7657e8a64749@users.sourceforge.net>
	<babc429d-6440-92aa-e1d0-eee2636a8d0f@users.sourceforge.net>
	<20170522094320.GE12205@stefanha-x1.localdomain>
	<557bdff4-6dc2-756d-0d59-9f688ef11f0a@users.sourceforge.net>
	<20170522112320.GA22806@stefanha-x1.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	netdev@vger.kernel.org, Wolfram Sang <wsa@the-dreams.de>,
	kernel-janitors@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	virtualization@lists.linux-foundation.org,
	SF Markus Elfring <elfring@users.sourceforge.net>
To: Stefan Hajnoczi <stefanha@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20170522112320.GA22806@stefanha-x1.localdomain>
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

On Mon, May 22, 2017 at 12:23:20PM +0100, Stefan Hajnoczi wrote:
> I'm not sure if kmalloc() and friends guarantee to show
> a message (not just the first time, but for every failed allocation)?
>

It prints multiple times, but it's ratelimited.  It can also be disabled
using a config option.

See slab_out_of_memory().

regards,
dan carpenter
