From: David Miller <davem@davemloft.net>
Subject: Re: [REGRESSION][PATCH V4 1/3] bpf jit: Make the
 filter.c::__load_pointer helper non-static for the jits
Date: Tue, 03 Apr 2012 18:02:12 -0400 (EDT)
Message-ID: <20120403.180212.1644422418766062447.davem@davemloft.net>
References: <4F75CA89.4010709@googlemail.com>
	<4F75CC63.10405@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, matt@ozlabs.org,
	eric.dumazet@gmail.com
To: kaffeemonster@googlemail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F75CC63.10405@googlemail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Seiffert <kaffeemonster@googlemail.com>
Date: Fri, 30 Mar 2012 17:08:19 +0200

> The function is renamed to make it a little more clear what it does.
> It is not added to any .h because it is not for general consumption, only for
> bpf internal use (and so by the jits).
> 
> Signed-of-by: Jan Seiffert <kaffeemonster@googlemail.com>

Applied but with comment formatting fixed up:

> +/*
> + * No hurry in this branch
> + *
> + * Exported for the bpf jit load helper.
> + */

Like this:

> +/* No hurry in this branch
> + *
> + * Exported for the bpf jit load helper.
> + */
