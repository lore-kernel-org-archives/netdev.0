From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: linux-next: build failure after merge of the moduleh tree
Date: Wed, 28 Sep 2011 19:42:35 +0300
Message-ID: <4E834E7B.3010405@qca.qualcomm.com>
References: <20110928183552.cb27a2b28b02fec275bca009@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	<linux-next@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Vasanthakumar Thiagarajan <vthiagar@qca.qualcomm.com>,
	Raja Mani <rmani@qca.qualcomm.com>,
	Vivek Natarajan <nataraja@qca.qualcomm.com>,
	Suraj Sumangala <surajs@qca.qualcomm.com>,
	Joe Perches <joe@perches.com>,
	Jouni Malinen <jouni@qca.qualcomm.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110928183552.cb27a2b28b02fec275bca009@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/28/2011 11:35 AM, Stephen Rothwell wrote:
> Hi Paul,
> 
> After merging the moduleh tree, today's linux-next build (x86_64
> allmodconfig) failed like this:
> 
> drivers/net/wireless/ath/ath6kl/init.c:27:26: error: expected ')' before 'uint'
> 
> Caused by commit bdcd81707973 ("Add ath6kl cleaned up driver") from the
> net tree interacting with the module.h split up.
> 
> I have applied the following patch for today (which sould be applied to
> the net or wireless trees).
> 
> From 1875bfc8881cca3064c7d7fad024555fe1652926 Mon Sep 17 00:00:00 2001
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Wed, 28 Sep 2011 18:32:34 +1000
> Subject: [PATCH] wireless/ath6kl: use of module_param requires the inclusion
>  of moduleparam.h
> 
> Otheriwse the module.h split up fails like this:
> 
> drivers/net/wireless/ath/ath6kl/init.c:27:26: error: expected ')' before 'uint'

Thanks, I applied this to ath6kl.git (had to fix just one conflict).
Later this week I will send a pull request to John so that the patch
should get to the wireless tree soon.

Unless John wants to take the patch directly, of course.

Kalle
