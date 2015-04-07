From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH ipsec] vti6: fix uninit when using x-netns
Date: Tue, 7 Apr 2015 10:59:16 +0200
Message-ID: <20150407085916.GI20559@secunet.com>
References: <1427988677-11478-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <herbert@gondor.apana.org.au>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, Yao Xiwei <xiwei.yao@6wind.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:60787 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752748AbbDGI7U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Apr 2015 04:59:20 -0400
Content-Disposition: inline
In-Reply-To: <1427988677-11478-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 02, 2015 at 05:31:17PM +0200, Nicolas Dichtel wrote:
> From: Yao Xiwei <xiwei.yao@6wind.com>
> 
> When the kernel deleted a vti6 interface, this interface was not removed from
> the tunnels list. Thus, when the ip6_vti module was removed, this old interface
> was found and the kernel tried to delete it again. This was leading to a kernel
> panic.
> 
> Fixes: 61220ab34948 ("vti6: Enable namespace changing")
> Signed-off-by: Yao Xiwei <xiwei.yao@6wind.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Patch applied to the ipsec tree, thanks a lot!
