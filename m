From: "Steve Wise" <swise@opengridcomputing.com>
Subject: RE: [net-next 2/6] cxgb3i,cxgb4i,libcxgbi: remove iSCSI DDP support
Date: Fri, 15 Jul 2016 09:05:32 -0500
Message-ID: <099301d1dea1$f36ec980$da4c5c80$@opengridcomputing.com>
References: <cover.1467998292.git.varun@chelsio.com> <73c3770a7b69e10c80b3f3a690c5819f735b1a28.1467998292.git.varun@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-scsi@vger.kernel.org>,
	<target-devel@vger.kernel.org>, <nab@linux-iscsi.org>,
	<gerlitz.or@gmail.com>, <james.bottomley@hansenpartnership.com>,
	<indranil@chelsio.com>
To: "'Varun Prakash'" <varun@chelsio.com>, <davem@davemloft.net>
Return-path: <target-devel-owner@vger.kernel.org>
In-Reply-To: <73c3770a7b69e10c80b3f3a690c5819f735b1a28.1467998292.git.varun@chelsio.com>
Content-Language: en-us
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Remove old ddp code from cxgb3i,cxgb4i,libcxgbi.
> 
> Next two commits adds DDP support using
> common iSCSI DDP Page Pod Manager.
> 
> Signed-off-by: Varun Prakash <varun@chelsio.com>
> ---
>  drivers/scsi/cxgbi/cxgb3i/cxgb3i.c | 128 --------
>  drivers/scsi/cxgbi/cxgb4i/cxgb4i.c | 142 ---------
>  drivers/scsi/cxgbi/libcxgbi.c      | 578
-------------------------------------
>  drivers/scsi/cxgbi/libcxgbi.h      | 161 -----------
>  4 files changed, 1009 deletions(-)

Looks good.  I guess this series needs to be squashed or we'll have bisect
compile problems?

Reviewed-by: Steve Wise <swise@opengridcomputing.com>
