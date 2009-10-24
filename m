From: David Miller <davem@davemloft.net>
Subject: Re: PATCH 23/10]Optimize the upload speed for PPP connection.
Date: Sat, 24 Oct 2009 06:46:03 -0700 (PDT)
Message-ID: <20091024.064603.249036129.davem@davemloft.net>
References: <fae097f21b27.1b27fae097f2@huawei.com>
	<4AE19780.3020507@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: huananhu@huawei.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, zihan@huawei.com, greg@kroah.com,
	haegar@sdinet.de
To: william.allen.simpson@gmail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753563AbZJXNpl@vger.kernel.org>
In-Reply-To: <4AE19780.3020507@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: William Allen Simpson <william.allen.simpson@gmail.com>
Date: Fri, 23 Oct 2009 07:46:08 -0400

> Concur.  I'd go further than that, my code usually made room for at
> least
> a full MTU (MRU) with HDLC escaping.  To minimize context switches,
> that
> should be 3014 ((1500 MRU + 2 FCS + 4 header) * 2 escapes + 2 flags).
> 
> Even in the old days, when memory was tight, context switches and
> interrupt
> time were more expensive, too.  PPP is supposed to scale to OC-192.

Actually I'd like to see ->obuf allocated externally and then
make it simply PAGE_SIZE.
