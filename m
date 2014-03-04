From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCHv3 net-next 29/31] iw_cxgb4: minor fixes
Date: Tue, 04 Mar 2014 20:43:42 +0300
Message-ID: <531610CE.7020608@cogentembedded.com>
References: <1393936917-25847-1-git-send-email-hariprasad@chelsio.com> <1393936917-25847-30-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1393936917-25847-30-git-send-email-hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello.

On 03/04/2014 03:41 PM, Hariprasad Shenai wrote:

> From: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>

> Added some missing debug stats.

> Use uninitialized_var().

> Initialize reserved fields in a FW work request.

    You should really split this patch.

> Signed-off-by: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
> ---
>   drivers/infiniband/hw/cxgb4/cq.c       | 2 +-
>   drivers/infiniband/hw/cxgb4/mem.c      | 6 +++++-
>   drivers/infiniband/hw/cxgb4/qp.c       | 2 ++
>   drivers/infiniband/hw/cxgb4/resource.c | 8 ++++++--
>   4 files changed, 14 insertions(+), 4 deletions(-)
[...]

> diff --git a/drivers/infiniband/hw/cxgb4/resource.c b/drivers/infiniband/hw/cxgb4/resource.c
> index cdef4d7..16982f2 100644
> --- a/drivers/infiniband/hw/cxgb4/resource.c
> +++ b/drivers/infiniband/hw/cxgb4/resource.c
[...]
> @@ -323,7 +327,7 @@ u32 c4iw_rqtpool_alloc(struct c4iw_rdev *rdev, int size)
>   	PDBG("%s addr 0x%x size %d\n", __func__, (u32)addr, size << 6);
>   	if (!addr)
>   		printk_ratelimited(KERN_WARNING MOD "%s: Out of RQT memory\n",
> -		       pci_name(rdev->lldi.pdev));
> +			pci_name(rdev->lldi.pdev));

    This is not indented enough anyway, the like should start under 
KERN_WARNING, according to the networking coding style. Moreover, this change 
is now undocumented in the changelog.

WBR, Sergei

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
