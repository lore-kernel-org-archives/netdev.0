From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1 net-next] net: dsa: replace count*size kmalloc by
 kmalloc_array
Date: Sun, 16 Nov 2014 14:43:55 -0500 (EST)
Message-ID: <20141116.144355.100657609191730461.davem@davemloft.net>
References: <1415990202-28673-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: fabf@skynet.be
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415990202-28673-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fabian Frederick <fabf@skynet.be>
Date: Fri, 14 Nov 2014 19:36:42 +0100

> kmalloc_array manages count*sizeof overflow.
> 
> Signed-off-by: Fabian Frederick <fabf@skynet.be>

Applied, and yes I read Joe's feedback and the rest of this thread
wrt. sizeof(u8/s8).  That can be done as a followup.
