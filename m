From: "Gustavo F. Padovan" <padovan@profusion.mobi>
Subject: Re: [PATCH] bluetooth: bnep: fix buffer overflow
Date: Mon, 14 Feb 2011 12:35:32 -0200
Message-ID: <20110214143532.GA2597@joana>
References: <1297680871-11617-1-git-send-email-segoon@openwall.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, security@kernel.org,
	Marcel Holtmann <marcel@holtmann.org>,
	"David S. Miller" <davem@davemloft.net>, Tejun Heo <tj@kernel.org>,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org
To: Vasiliy Kulikov <segoon@openwall.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1297680871-11617-1-git-send-email-segoon@openwall.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Vasiliy,

* Vasiliy Kulikov <segoon@openwall.com> [2011-02-14 13:54:31 +0300]:

> Struct ca is copied from userspace.  It is not checked whether the "device"
> field is NULL terminated.  This potentially leads to BUG() inside of
> alloc_netdev_mqs() and/or information leak by creating a device with a name
> made of contents of kernel stack.
> 
> Signed-off-by: Vasiliy Kulikov <segoon@openwall.com>
> ---
>  Compile tested.
> 
>  net/bluetooth/bnep/sock.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)

Applied, thanks.

-- 
Gustavo F. Padovan
http://profusion.mobi
