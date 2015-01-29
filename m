From: Thomas Graf <tgraf@suug.ch>
Subject: Re: linux-next - crashes in rhashtable_shrink
Date: Thu, 29 Jan 2015 15:00:47 +0000
Message-ID: <20150129150047.GB12634@casper.infradead.org>
References: <5398.1422543462@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5398.1422543462@turing-police.cc.vt.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/29/15 at 09:57am, Valdis Kletnieks wrote:
> For the past few kernels, I've seen occasional crashes in rhashtable_shrink.
> Looks like the last thing to touch that code was the patch series:
> 
> Subject	[PATCH 0/9 net-next v2] rhashtable: Per bucket locks & deferred table resizing
> Date	Fri, 2 Jan 2015 23:00:13 +0100

Thanks for the report! Based on a similar report I've already tracked
this down to race condition. I'm in the final stages of submitting a
series of fixes for it.
