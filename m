From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: fix under-evaluated ssthresh in TCP Vegas
Date: Fri, 29 Sep 2017 06:07:39 +0100 (WEST)
Message-ID: <20170929.060739.1147658023007397220.davem@davemloft.net>
References: <1506529940-2143-1-git-send-email-hoang.tran@uclouvain.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hoang.tran@uclouvain.be,
        kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org,
        linux-kernel@vger.kernel.org
To: tranviethoang.vn@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1506529940-2143-1-git-send-email-hoang.tran@uclouvain.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hoang Tran <tranviethoang.vn@gmail.com>
Date: Wed, 27 Sep 2017 18:30:58 +0200

> With the commit 76174004a0f19785 (tcp: do not slow start when cwnd equals
> ssthresh), the comparison to the reduced cwnd in tcp_vegas_ssthresh() would
> under-evaluate the ssthresh.
> 
> Signed-off-by: Hoang Tran <hoang.tran@uclouvain.be>

Applied, thank you.
