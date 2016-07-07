From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [patch -next] bnxt: fix a condition
Date: Thu, 7 Jul 2016 01:31:46 -0700
Message-ID: <CACKFLi=yLRcJKvRHvh633+-2cqL6KcJsexzP4aMh1MvUPvnF6A@mail.gmail.com>
References: <20160707082309.GC16742@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Jeffrey Huang <huangjw@broadcom.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	Netdev <netdev@vger.kernel.org>, kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20160707082309.GC16742@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 7, 2016 at 1:23 AM, Dan Carpenter <dan.carpenter@oracle.com> wrote:
> This code generates as static checker warning because htons(ETH_P_IPV6)
> is always true.  From the context it looks like the && was intended to
> be !=.
>
> Fixes: 94758f8de037 ('bnxt_en: Add GRO logic for BCM5731X chips.')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Thanks.  The fix is correct.

Acked-by: Michael Chan <michael.chan@broadcom.com>
