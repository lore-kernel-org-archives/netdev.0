From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cxgb4/csiostor: Don't use MASTER_MUST for fw_hello call
Date: Thu, 11 Dec 2014 14:25:43 -0500 (EST)
Message-ID: <20141211.142543.465362034244812431.davem@davemloft.net>
References: <1418276503-23001-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	JBottomley@parallels.com, hch@infradead.org, leedom@chelsio.com,
	anish@chelsio.com, nirranjan@chelsio.com, praveenm@chelsio.com
To: hariprasad@chelsio.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1418276503-23001-1-git-send-email-hariprasad@chelsio.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Thu, 11 Dec 2014 11:11:43 +0530

> Remove use of calls into t4_fw_hello() with MASTER_MUST, which results in
> FW_HELLO_CMD_MASTERFORCE being set. The firmware doesn't support this and of
> course any existing PF Drivers will totally go for a toss.
> 
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

Applied, thanks.
