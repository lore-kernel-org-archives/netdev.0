From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 3.4-stable v2] ipv6: reallocate addrconf router for ipv6
 address when lo device up
Date: Wed, 6 Aug 2014 09:54:12 -0700
Message-ID: <20140806165412.GA11827@kroah.com>
References: <53E1E4C9.4010006@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, stable@vger.kernel.org,
	Sabrina Dubroca <sd@queasysnail.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Gao feng <gaofeng@cn.fujitsu.com>,
	Li Zefan <lizefan@huawei.com>
To: chenweilong <chenweilong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:36298 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932404AbaHFQyo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2014 12:54:44 -0400
Content-Disposition: inline
In-Reply-To: <53E1E4C9.4010006@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 06, 2014 at 04:18:17PM +0800, chenweilong wrote:
> It fix the bug 67951 on bugzilla
> https://bugzilla.kernel.org/show_bug.cgi?id=67951
> 
> The patch can't be applied directly, as it' used the function introduced
> by "commit 94e187c0" ip6_rt_put(), that patch can't be applied directly
> either.

Much better, thanks for the fixed patch.

greg k-h
