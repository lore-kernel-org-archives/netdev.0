From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH next-next-2.6] netdev: better dev_name_hash
Date: Sun, 25 Oct 2009 21:43:57 -0700
Message-ID: <20091025214357.666350d2@nehalam>
References: <200910252158.53921.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43102 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753300AbZJZEn7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Oct 2009 00:43:59 -0400
In-Reply-To: <200910252158.53921.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 25 Oct 2009 21:58:53 +0200
Octavian Purdila <opurdila@ixiacom.com> wrote:

> 
> The current dev_name_hash is not very good at spreading entries when a
> large number of interfaces of the same type (e.g. ethXXXXX) are used.
> 
> Here are some performance numbers for creating 16000 dummy interfaces with
> and without the patch (with per device sysctl entries disabled)
> 
>     With patch                      Without patch
> 
>     real    0m 2.27s                real    0m 4.32s
>     user    0m 0.00s                user    0m 0.00s
>     sys     0m 1.13s                sys     0m 2.16s
> 
> Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
> ---
>  net/core/dev.c |    8 +++++++-
>  1 files changed, 7 insertions(+), 1 deletions(-)

My $.02 would for fixing full name hash because other usages would
benefit as well.  Inventing special case for network devices seems
unnecessary.

-- 
