From: Mohammed Shafi Shajakhan <mohammed@qca.qualcomm.com>
Subject: Re: linux-next: manual merge of the net-next tree with the wireless
 tree
Date: Thu, 14 Jun 2012 10:20:13 +0530
Message-ID: <4FD96D85.4010505@qca.qualcomm.com>
References: <20120614131256.2fed671219b8d571a47987c2@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-next@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Sujith Manoharan <c_manoha@qca.qualcomm.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120614131256.2fed671219b8d571a47987c2@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

On Thursday 14 June 2012 08:42 AM, Stephen Rothwell wrote:
> Hi all,
>
> Today's linux-next merge of the net-next tree got a conflict in
> drivers/net/wireless/ath/ath9k/main.c between commit bcb7ad7bcbef
> ("ath9k: Fix softlockup in AR9485") from the wireless tree and commit
> ef1b6cd9a1ba ("ath9k: Group link monitoring logic") from the net-next
> tree.
>
> The latter removes the code modified by the former, so I did that.  The
> fix from the former patch may be needed elsewhere now.

the back ported version of this patch is recently sent
http://www.spinics.net/lists/linux-wireless/msg92125.html


-- 
thanks,
shafi
