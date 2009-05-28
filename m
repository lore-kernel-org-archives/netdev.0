From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [patch 2.6.31 08/10] wimax: Add netlink interface to get device
 state
Date: Wed, 27 May 2009 18:21:57 -0700
Message-ID: <20090527182157.48a3f4b0@nehalam>
References: <cover.1243472509.git.inaky@linux.intel.com>
	<e9de4b9426eeeddf56110425cfd88e43828e7146.1243472510.git.inaky@linux.intel.com>
	<22d4458f609ba31f1382e25844125e421dcd4163.1243472510.git.inaky@linux.intel.com>
	<05962df1398ad316feb1e20160b7502731bebc97.1243472510.git.inaky@linux.intel.com>
	<ba98dde3cde9f5910789b32852c692fc8cd0a4aa.1243472510.git.inaky@linux.intel.com>
	<74bd64a25b220d21e50c7c9a85f26ff6617b3728.1243472510.git.inaky@linux.intel.com>
	<f3aea79091a4fc501235f2e743cc073ebd962934.1243472510.git.inaky@linux.intel.com>
	<d791bac79c5e9840a3e5317a4bb79acafde911f9.1243472510.git.inaky@linux.intel.com>
	<4d58364611c66a20ea1e28223b8f638fd2e35981.1243472510.git.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wimax@linuxwimax.org,
	Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
To: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56424 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751999AbZE1BWC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 May 2009 21:22:02 -0400
In-Reply-To: <4d58364611c66a20ea1e28223b8f638fd2e35981.1243472510.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 27 May 2009 18:05:13 -0700
Inaky Perez-Gonzalez <inaky@linux.intel.com> wrote:

> From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
> 
> wimax connection manager / daemon has to know what is current
> state of the device. Previously it was only possible to get
> notification whet state has changed.
> 
> Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
> ---
>  include/linux/wimax.h    |    5 +++
>  net/wimax/Makefile       |    1 +
>  net/wimax/debug-levels.h |    1 +
>  net/wimax/debugfs.c      |    1 +
>  net/wimax/op-state-get.c |   86 ++++++++++++++++++++++++++++++++++++++++++++++
>  net/wimax/stack.c        |    5 ++-
>  6 files changed, 98 insertions(+), 1 deletions(-)
>  create mode 100644 net/wimax/op-state-get.c
> 
> diff --git a/include/linux/wimax.h b/include/linux/wimax.h
> index c89de7f..c750f42 100644
> --- a/include/linux/wimax.h
> +++ b/include/linux/wimax.h
> @@ -77,6 +77,7 @@ enum {
>  	WIMAX_GNL_OP_MSG_TO_USER,	/* Kernel to user message */
>  	WIMAX_GNL_OP_RFKILL,	/* Run wimax_rfkill() */
>  	WIMAX_GNL_OP_RESET,	/* Run wimax_rfkill() */
> +	WIMAX_GNL_OP_STATE_GET,		/* Request for current state */
>  	WIMAX_GNL_RE_STATE_CHANGE,	/* Report: status change */
>  };

Won't adding new element in middle of list break existing ABI?
