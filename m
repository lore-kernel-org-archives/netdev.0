From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 08/14] netlink: implement memory mapped sendmsg()
Date: Wed, 17 Apr 2013 23:57:43 +0100
Message-ID: <1366239463.2752.3.camel@bwh-desktop.uk.solarflarecom.com>
References: <1366217229-22705-1-git-send-email-kaber@trash.net>
	 <1366217229-22705-9-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netfilter-devel@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1366217229-22705-9-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-04-17 at 18:47 +0200, Patrick McHardy wrote:
> Add support for mmap'ed sendmsg() to netlink. Since the kernel validates
> received messages before processing them, the code makes sure userspace
> can't modify the message contents after invoking sendmsg(). To do that
> only a single mapping of the TX ring is allowed to exist and the socket
> must not be shared. If either of these two conditions does not hold, it
> falls back to copying.
[...]

Is this resistant against copy_to_process()?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

