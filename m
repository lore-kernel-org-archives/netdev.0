From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] irda: Fix likely typo in output format string
Date: Wed, 31 Aug 2016 14:31:51 -0700 (PDT)
Message-ID: <20160831.143151.313012072430161185.davem@davemloft.net>
References: <1472267646-810675-1-git-send-email-green@linuxhacker.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: green@linuxhacker.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1472267646-810675-1-git-send-email-green@linuxhacker.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Oleg Drokin <green@linuxhacker.ru>
Date: Fri, 26 Aug 2016 23:14:06 -0400

> %ul would print an unsigned with a letter l at the end which does
> not seem to be desired here, on the other hand the value being printed
> is u32 so just drop the l instead of converting to %lu
> 
> Signed-off-by: Oleg Drokin <green@linuxhacker.ru>

%u is for unsigned values, and these are "s32" thus signed.
