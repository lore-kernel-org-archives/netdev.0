From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH 14/62] cxgb4vf: Use static const
Date: Mon, 22 Nov 2010 09:42:40 -0800
Message-ID: <201011220942.40414.leedom@chelsio.com>
References: <cover.1290305773.git.joe@perches.com> <d0a433aa6bbe20dfe4fd4f3ca9aec50f97601403.1290305776.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:26775 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753602Ab0KVRmn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Nov 2010 12:42:43 -0500
In-Reply-To: <d0a433aa6bbe20dfe4fd4f3ca9aec50f97601403.1290305776.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| From: Joe Perches <joe@perches.com>
| Date: Saturday, November 20, 2010 06:38 pm
| 
| Using static const generally increases object text and decreases data size.
| It also generally decreases overall object size.
| 
|    text	   data	    bss	    dec	    hex	filename
|   10179	     56	   2216	  12451	   30a3	drivers/net/cxgb4vf/t4vf_hw.o.new
|   10179	     56	   2216	  12451	   30a3	drivers/net/cxgb4vf/t4vf_hw.o.old
| 
| Signed-off-by: Joe Perches <joe@perches.com>
| ---
|  drivers/net/cxgb4vf/t4vf_hw.c |    2 +-
|  1 files changed, 1 insertions(+), 1 deletions(-)
| 
| diff --git a/drivers/net/cxgb4vf/t4vf_hw.c b/drivers/net/cxgb4vf/t4vf_hw.c
| index f7d7f97..daedf6e 100644
| --- a/drivers/net/cxgb4vf/t4vf_hw.c
| +++ b/drivers/net/cxgb4vf/t4vf_hw.c
| @@ -116,7 +116,7 @@ static void dump_mbox(struct adapter *adapter, const
| char *tag, u32 mbox_data) int t4vf_wr_mbox_core(struct adapter *adapter,
| const void *cmd, int size, void *rpl, bool sleep_ok)
|  {
| -	static int delay[] = {
| +	static const int delay[] = {
|  		1, 1, 3, 5, 10, 10, 20, 50, 100
|  	};

  Looks okay to me.  Thanks!

Casey
