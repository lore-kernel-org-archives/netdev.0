From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 0/3] some fixes of tuntap
Date: Fri, 11 Jan 2013 19:42:16 -0800 (PST)
Message-ID: <20130111.194216.884859016289350447.davem@davemloft.net>
References: <1357959574-13113-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, edumazet@google.com,
	stefanha@redhat.com
To: jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1357959574-13113-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Wang <jasowang@redhat.com>
Date: Sat, 12 Jan 2013 10:59:31 +0800

> There series fixes two issues:
> - Don't allow calling TUNSETIFF when a file is detached which may cause kernel
> data structure corrupt.
> - Fix the reference count leaking of sock and module.
> 
> Plus a suggestion from Eric to use rtnl_dereference() instead of the open code.
> 
> Changes from v1:
> - don't use rcu to dereference tfile->detached as it was already protected by
> rtnl lock.
> - add a patch of switching to use rtnl_dereference().

All applied, thanks Jason.
