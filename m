From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: Re: [PATCH 1/5] qlge: Convert /n to \n
Date: Fri, 25 Apr 2014 04:07:58 +0000
Message-ID: <BECD8E8A1B550B48A1BF97C13991F60E46D4E975@avmb2.qlogic.org>
References: <cover.1398390579.git.joe@perches.com>
 <0cfcf37f20b78a2bc3cde9f56aa27ca53a802184.1398390579.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Ron Mercer <ron.mercer@qlogic.com>,
	Dept-Eng Linux Driver <Linux-Driver@qlogic.com>,
	netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>,
	linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0cfcf37f20b78a2bc3cde9f56aa27ca53a802184.1398390579.git.joe@perches.com>
Content-Language: en-US
Content-ID: <F00F37E7108B224E89CD25BD7B9B7A9C@qlogic.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/24/14 6:50 PM, "Joe Perches" <joe@perches.com> wrote:

>Use a newline character appropriately.
>
>Signed-off-by: Joe Perches <joe@perches.com>
>---
> drivers/net/ethernet/qlogic/qlge/qlge_main.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
>
>diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
>b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
>index 0a1d76a..6e36fe1 100644
>--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
>+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
>@@ -3595,7 +3595,7 @@ static int ql_request_irq(struct ql_adapter *qdev)
> 	}
> 	return status;
> err_irq:
>-	netif_err(qdev, ifup, qdev->ndev, "Failed to get the interrupts!!!/n");
>+	netif_err(qdev, ifup, qdev->ndev, "Failed to get the interrupts!!!\n");
> 	ql_free_irq(qdev);
> 	return status;
> }
>-- 
>1.8.1.2.459.gbcd45b4.dirty
Acked-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
