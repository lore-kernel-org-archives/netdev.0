From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [net-next v2 07/14] i40evf: remove double space after return
Date: Fri, 28 Mar 2014 22:58:31 +0300
Message-ID: <CAJZOPZ+NqT8LsJGjtmZGwUANONXphgtm1tZSdoLrRiDyruyJ0Q@mail.gmail.com>
References: <1396015695-25283-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1396015695-25283-8-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:36605 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751435AbaC1T6b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 15:58:31 -0400
Received: by mail-pa0-f46.google.com with SMTP id kp14so5442270pab.19
        for <netdev@vger.kernel.org>; Fri, 28 Mar 2014 12:58:31 -0700 (PDT)
In-Reply-To: <1396015695-25283-8-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 28, 2014 at 5:08 PM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
>
> There were two spaces between return and the value, we only need one.
>
> Change-ID: Iaa42c33f50d8d149cdf1a4c9c1902295bfd991c4
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Acked-by: Shannon Nelson <shannon.nelson@intel.com>
> Signed-off-by: Kevin Scott <kevin.c.scott@intel.com>
> Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
> Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Just out of curiosity, any special reason for four of the maintainers
to sign on a patch that remove a space?

>
> ---
>  drivers/net/ethernet/intel/i40evf/i40e_prototype.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/intel/i40evf/i40e_prototype.h b/drivers/net/ethernet/intel/i40evf/i40e_prototype.h
> index 862fcdf..97ab8c2 100644
> --- a/drivers/net/ethernet/intel/i40evf/i40e_prototype.h
> +++ b/drivers/net/ethernet/intel/i40evf/i40e_prototype.h
> @@ -67,7 +67,7 @@ extern struct i40e_rx_ptype_decoded i40evf_ptype_lookup[];
>
>  static inline struct i40e_rx_ptype_decoded decode_rx_desc_ptype(u8 ptype)
>  {
> -       return  i40evf_ptype_lookup[ptype];
> +       return i40evf_ptype_lookup[ptype];
>  }
>
>  /* prototype for functions used for SW locks */
> --
> 1.9.0
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
