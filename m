From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] af_unix: implement socket filter
Date: Tue, 18 Jan 2011 21:33:27 -0800 (PST)
Message-ID: <20110118.213327.27785301.davem@davemloft.net>
References: <1295368755-20931-1-git-send-email-ian.molton@collabora.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	eric.dumazet@gmail.com, ebiederm@xmission.com, xemul@openvz.org,
	davidel@xmailserver.org, alban.crequy@collabora.co.uk
To: ian.molton@collabora.co.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1295368755-20931-1-git-send-email-ian.molton@collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ian Molton <ian.molton@collabora.co.uk>
Date: Tue, 18 Jan 2011 16:39:15 +0000

> From: Alban Crequy <alban.crequy@collabora.co.uk>
> 
> Linux Socket Filters can already be successfully attached and detached on unix
> sockets with setsockopt(sockfd, SOL_SOCKET, SO_{ATTACH,DETACH}_FILTER, ...).
> See: Documentation/networking/filter.txt
> 
> But the filter was never used in the unix socket code so it did not work. This
> patch uses sk_filter() to filter buffers before delivery.
> 
> This short program demonstrates the problem on SOCK_DGRAM.
...
> Signed-off-by: Alban Crequy <alban.crequy@collabora.co.uk>
> Reviewed-by: Ian Molton <ian.molton@collabora.co.uk>

Applied.
