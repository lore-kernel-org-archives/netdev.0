From: Keith Owens <kaos@ocs.com.au>
Subject: Re: [PATCH 1/1] network memory allocator.
Date: Mon, 14 Aug 2006 22:07:48 +1000
Message-ID: <9286.1155557268@ocs10w.ocs.com.au>
References: <20060814110359.GA27704@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932282AbWHNMHu@vger.kernel.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-reply-to: Your message of "Mon, 14 Aug 2006 15:04:03 +0400."
             <20060814110359.GA27704@2ka.mipt.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov (on Mon, 14 Aug 2006 15:04:03 +0400) wrote:
>Network tree allocator can be used to allocate memory for all network
>operations from any context....
>...
>Design of allocator allows to map all node's pages into userspace thus
>allows to have true zero-copy support for both sending and receiving
>dataflows.

Is that true for architectures with virtually indexed caches?  How do
you avoid the cache aliasing problems?
