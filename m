From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: compat: Update get_compat_msghdr() to match
 copy_msghdr_from_user() behaviour
Date: Fri, 20 Mar 2015 16:32:17 -0400 (EDT)
Message-ID: <20150320.163217.1133959916107908748.davem@davemloft.net>
References: <1426870093-7616-1-git-send-email-catalin.marinas@arm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	will.deacon@arm.com, dan.carpenter@oracle.com
To: catalin.marinas@arm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1426870093-7616-1-git-send-email-catalin.marinas@arm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Catalin Marinas <catalin.marinas@arm.com>
Date: Fri, 20 Mar 2015 16:48:13 +0000

> Commit db31c55a6fb2 (net: clamp ->msg_namelen instead of returning an
> error) introduced the clamping of msg_namelen when the unsigned value
> was larger than sizeof(struct sockaddr_storage). This caused a
> msg_namelen of -1 to be valid. The native code was subsequently fixed by
> commit dbb490b96584 (net: socket: error on a negative msg_namelen).
> 
> In addition, the native code sets msg_namelen to 0 when msg_name is
> NULL. This was done in commit (6a2a2b3ae075 net:socket: set msg_namelen
> to 0 if msg_name is passed as NULL in msghdr struct from userland) and
> subsequently updated by 08adb7dabd48 (fold verify_iovec() into
> copy_msghdr_from_user()).
> 
> This patch brings the get_compat_msghdr() in line with
> copy_msghdr_from_user().
> 
> Fixes: db31c55a6fb2 (net: clamp ->msg_namelen instead of returning an error)
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>

Applied and queued up for -stable, thanks.
