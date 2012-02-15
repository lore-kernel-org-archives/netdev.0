From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [patch] iproute: fix dangerous /tmp/ handling
Date: Wed, 15 Feb 2012 08:50:29 -0800
Message-ID: <20120215085029.45278e27@nehalam.linuxnetplumber.net>
References: <20120215123223.GA14094@albatros>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, security@kernel.org, shemminger@osdl.org,
	kuznet@ms2.inr.ac.ru, Solar Designer <solar@openwall.com>
To: Vasiliy Kulikov <segoon@openwall.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47211 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750862Ab2BOQuh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Feb 2012 11:50:37 -0500
In-Reply-To: <20120215123223.GA14094@albatros>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 15 Feb 2012 16:32:23 +0400
Vasiliy Kulikov <segoon@openwall.com> wrote:

>  INCLUDE=${1:-"$PWD/include"}
>  
> +TMPDIR="`mktemp -dt iproute.XXXXXXXXXX`" || exit

I will add a variation on this patch based on current code used by
autoconf tools that puts files in the build location instead
of /tmp.
