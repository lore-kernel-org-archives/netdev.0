From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] jhash: fix -Wimplicit-fallthrough warnings
Date: Mon, 17 Jul 2017 09:23:28 -0700 (PDT)
Message-ID: <20170717.092328.27327361173214982.davem@davemloft.net>
References: <20170715060349.2464-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kadlec@blackhole.kfki.hu, oss-drivers@netronome.com
To: jakub.kicinski@netronome.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170715060349.2464-1-jakub.kicinski@netronome.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Fri, 14 Jul 2017 23:03:49 -0700

> GCC 7 added a new -Wimplicit-fallthrough warning.  It's only enabled
> with W=1, but since linux/jhash.h is included in over hundred places
> (including other global headers) it seems worthwhile fixing this
> warning.
> 
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> ---
> If it looks good, would it be OK to take it via the net tree?

Applied, thanks Jakub.
