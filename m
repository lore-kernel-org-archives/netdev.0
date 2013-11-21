From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] wimax: remove dead code
Date: Wed, 20 Nov 2013 20:17:49 -0800
Message-ID: <1385007469.2164.39.camel@joe-AO722>
References: <1385005391-18379-1-git-send-email-michael.opdenacker@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: inaky.perez-gonzalez@intel.com, linux-wimax@intel.com,
	davem@davemloft.net, wimax@linuxwimax.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Michael Opdenacker <michael.opdenacker@free-electrons.com>,
	Johannes Berg <johannes.berg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0165.hostedemail.com ([216.40.44.165]:54157 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751714Ab3KUERy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 23:17:54 -0500
In-Reply-To: <1385005391-18379-1-git-send-email-michael.opdenacker@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-11-21 at 04:43 +0100, Michael Opdenacker wrote:
> This removes a code line that is between a "return 0;" and an error label.
> This code line can never be reached.

Adding Johannes Berg who added this oversight.

> Found by Coverity (CID: 1130529)
> 
> Signed-off-by: Michael Opdenacker <michael.opdenacker@free-electrons.com>
> ---
>  net/wimax/stack.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/net/wimax/stack.c b/net/wimax/stack.c
> index ef2191b969a7..ec8b577db135 100644
> --- a/net/wimax/stack.c
> +++ b/net/wimax/stack.c
> @@ -610,7 +610,6 @@ int __init wimax_subsys_init(void)
>  	d_fnend(4, NULL, "() = 0\n");
>  	return 0;
>  
> -	genl_unregister_family(&wimax_gnl_family);
>  error_register_family:
>  	d_fnend(4, NULL, "() = %d\n", result);
>  	return result;
