From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 0/4] ath10k: a few incorrect return handling fix-up
Date: Tue, 30 Dec 2014 20:18:52 +0300
Message-ID: <54A2DE7C.1050602@cogentembedded.com>
References: <1419942046-17985-1-git-send-email-der.herr@hofr.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michal Kazior <michal.kazior@tieto.com>,
	Ben Greear <greearb@candelatech.com>,
	Chun-Yeow Yeoh <yeohchunyeow@gmail.com>,
	Yanbo Li <yanbol@qti.qualcomm.com>, ath10k@lists.infradead.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Nicholas Mc Guire <der.herr@hofr.at>,
	Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1419942046-17985-1-git-send-email-der.herr@hofr.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 12/30/2014 03:20 PM, Nicholas Mc Guire wrote:

> wait_for_completion_timeout does not return negative values so the tests
> for <= 0 are not needed and the case differentiation in the error handling
> path unnecessary.

    I decided to verify your statement and I saw that it seems wrong. 
do_wait_for_common() can return -ERESTARTSYS and the return value gets 
returned by its callers unchanged.

> patch was only compile tested x86_64_defconfig + CONFIG_ATH_CARDS=m
> CONFIG_ATH10K=m

> patch is against linux-next 3.19.0-rc1 -next-20141226

    Rather patches. It would have been better to send one patch instead of 4 
patches with the same name.

WBR, Sergei
