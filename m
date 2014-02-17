From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [REGRESSION v3.14-rc2] NULL dereference in icmp6_send()
Date: Mon, 17 Feb 2014 14:43:14 -0500
Message-ID: <20140217194314.GD16660@thunk.org>
References: <nsxzjlp4lxm.fsf@closure.thunk.org>
 <20140217185053.GF22833@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140217185053.GF22833@order.stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 17, 2014 at 07:50:53PM +0100, Hannes Frederic Sowa wrote:
> At that point the skb does not have a dst attached, so we panic in
> icmp6_send.
> 
> This is fixed here:
> https://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=d94c1f92bbf2c42c5febd68bbea51fffeac90834

Thanks!!

BTW, apologies for the inadvertent share of the photo to my G+ stream.
I had taken the photo using my cell phone, and I was trying to make
sure the URL was publically viewable before I filed the bug report.

					- Ted
