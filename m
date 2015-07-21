From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ravb: fix race updating TCCR
Date: Mon, 20 Jul 2015 20:42:21 -0700 (PDT)
Message-ID: <20150720.204221.665725597328229621.davem@davemloft.net>
References: <6587398.M5V25fvqHl@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <6587398.M5V25fvqHl@wasted.cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Fri, 17 Jul 2015 00:28:38 +0300

> The TCCR.TSRQn bit may get clearead after TCCR gets read, so that TCCR write
> would get skipped. We don't need to check this bit before setting.
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied, thanks.
