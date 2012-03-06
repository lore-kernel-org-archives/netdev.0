From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH] net: make CONFIG_BQL actually end user configurable
Date: Mon, 05 Mar 2012 20:11:26 -0800
Message-ID: <4F558E6E.4000707@intel.com>
References: <1331005096-12332-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, davem@davemloft.net, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:64454 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964934Ab2CFEL2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Mar 2012 23:11:28 -0500
In-Reply-To: <1331005096-12332-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/5/2012 7:38 PM, Paul Gortmaker wrote:
> Without the defining string or help text, LKC won't ever bother
> to ask the end user for a setting for CONFIG_BQL -- you could
> delete it from your .config and run make oldconfig and not a
> thing would change -- it would still be silently re-enabled.
> 
> While most people will have no reason to turn this off, the
> ability to do so can be useful for testing BQL support additions
> on previously BQL-unaware drivers and similar.
> 
> The kconfig help text is largely taken from the original RFC
> patchset 0/N header sent to netdev@vger.kernel.org in fall 2011.
> 
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> ---
> 
> [Apologies if this was explicitly blocked for a reason; I couldn't
>  find a reason after searching netdev or threads at bufferbloat.net ]
> 

It was intentional "The Kconfig entry and option is merely for
expressing internal dependencies,". See the comments in the patch

http://patchwork.ozlabs.org/patch/128727/

And corresponding mail,

http://lists.openwall.net/netdev/2011/12/01/130

.John
