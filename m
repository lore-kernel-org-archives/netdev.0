From: KY Srinivasan <kys@microsoft.com>
Subject: RE: linux-next: manual merge of the net-next tree with Linus' tree
Date: Thu, 5 Jun 2014 03:26:45 +0000
Message-ID: <1290247eb26c49229a7fcb49021a365f@BY2PR03MB299.namprd03.prod.outlook.com>
References: <20140605131359.771694b6@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Greg Kroah-Hartman" <gregkh@linuxfoundation.org>,
	stephen hemminger <stephen@networkplumber.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20140605131359.771694b6@canb.auug.org.au>
Content-Language: en-US
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Stephen Rothwell [mailto:sfr@canb.auug.org.au]
> Sent: Wednesday, June 4, 2014 8:14 PM
> To: David Miller; netdev@vger.kernel.org
> Cc: linux-next@vger.kernel.org; linux-kernel@vger.kernel.org; KY Srinivasan;
> Greg Kroah-Hartman; stephen hemminger
> Subject: linux-next: manual merge of the net-next tree with Linus' tree
> 
> Hi all,
> 
> Today's linux-next merge of the net-next tree got a conflict in
> drivers/hv/channel_mgmt.c between commit d3ba720dd58c ("Drivers: hv:
> Eliminate the channel spinlock in the callback path") from Linus' tree and
> commit 1b9d48f2a579 ("hyper-v: make uuid_le const") from the net-next
> tree.
> 
> I fixed it up (see below) and can carry the fix as necessary (no action is
> required).

Thanks Stephen.

Regards,

K. Y
> 
> --
> Cheers,
> Stephen Rothwell                    sfr@canb.auug.org.au
> 
> diff --cc drivers/hv/channel_mgmt.c
> index 6c8b032cacba,90d654556437..000000000000
> --- a/drivers/hv/channel_mgmt.c
> +++ b/drivers/hv/channel_mgmt.c
> @@@ -404,7 -365,7 +404,7 @@@ static u32  next_vp
>    * performance critical channels (IDE, SCSI and Network) will be uniformly
>    * distributed across all available CPUs.
>    */
> - static void init_vp_index(struct vmbus_channel *channel, uuid_le
> *type_guid)  -static u32 get_vp_index(const uuid_le *type_guid)
> ++static void init_vp_index(struct vmbus_channel *channel, const uuid_le
> ++*type_guid)
>   {
>   	u32 cur_cpu;
>   	int i;
