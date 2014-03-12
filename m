From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next 12/13] ixgbe: fix some multiline hw_dbg prints
Date: Wed, 12 Mar 2014 18:51:05 +0400
Message-ID: <53207459.5010306@cogentembedded.com>
References: <1394603618-1044-1-git-send-email-jeffrey.t.kirsher@intel.com> <1394603618-1044-13-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:61518 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754210AbaCLOvK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 10:51:10 -0400
Received: by mail-lb0-f170.google.com with SMTP id s7so6812513lbd.1
        for <netdev@vger.kernel.org>; Wed, 12 Mar 2014 07:51:09 -0700 (PDT)
In-Reply-To: <1394603618-1044-13-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12-03-2014 9:53, Jeff Kirsher wrote:

> From: Jacob Keller <jacob.e.keller@intel.com>

> This patch fixes some formatting on multilined print messages, so that
> the text of the print appears on a single line, which aids in grepping
> the sourcecode for where the error came from.

> Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
> Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>   drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c | 8 +++-----
>   1 file changed, 3 insertions(+), 5 deletions(-)

> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
> index 446df3c..3bc9b67 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
> @@ -512,7 +512,7 @@ out:
>    *
>    * Disables link, should be called during D3 power down sequence.
>    *
> - */
> + **/

    Hm? What's this for?

WBR, Sergei
