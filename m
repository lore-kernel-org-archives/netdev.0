From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] ethtool: Add support for setting multiple rx/tx queues
Date: Thu, 02 Aug 2007 17:18:51 -0700
Message-ID: <46B2746B.6050601@intel.com>
References: <20070731202156.15813.98302.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Auke Kok <auke-jan.h.kok@intel.com>, jgarzik@pobox.com,
	davem@davemloft.net,
	"Nunley, Nicholas D" <nicholas.d.nunley@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:28324 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758682AbXHCAS7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Aug 2007 20:18:59 -0400
In-Reply-To: <20070731202156.15813.98302.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
> @@ -496,6 +516,14 @@ static void parse_cmdline(int argc, char **argp)
>  				i = argc;
>  				break;
>  			}
> +			if (mode == MODE_SQUEUE) {
> +				parse_generic_cmdline(argc, argp, i,
> +					&gqueue_changed,
> +					cmdline_ring,

Nick pointed out the obvious typo here... I'll wait for some (more) comments 
before reposting.

Auke
