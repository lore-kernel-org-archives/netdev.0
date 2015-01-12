From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: [PATCH v3] ath10k: fixup wait_for_completion_timeout return handling
Date: Mon, 12 Jan 2015 14:39:22 +0200
Message-ID: <878uh8dvgl.fsf@kamboji.qca.qualcomm.com>
References: <1420720054-27870-1-git-send-email-der.herr@hofr.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Chun-Yeow Yeoh <yeohchunyeow@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	<netdev@vger.kernel.org>, <linux-wireless@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <ath10k@lists.infradead.org>,
	Michal Kazior <michal.kazior@tieto.com>,
	Yanbo Li <yanbol@qca.qualcomm.com>,
	Ben Greear <greearb@candelatech.com>
To: Nicholas Mc Guire <der.herr@hofr.at>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420720054-27870-1-git-send-email-der.herr@hofr.at> (Nicholas Mc
	Guire's message of "Thu, 8 Jan 2015 13:27:34 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nicholas Mc Guire <der.herr@hofr.at> writes:

> wait_for_completion_timeout does not return negative values so the tests
> for <= 0 are not needed and the case differentiation in the error handling
> path unnecessary.
>
> v2: all wait_for_completion_timeout changes in a single patch
> v3: patch formatting cleanups - no change of actual patch
>
> Signed-off-by: Nicholas Mc Guire <der.herr@hofr.at>
> ---
> patch was only compile tested x86_64_defconfig + CONFIG_ATH_CARDS=m
> CONFIG_ATH10K=m
>
> patch is against linux-next 3.19.0-rc1 -next-20141226
>
> None of the proposed cleanups are critical.
> All changes should only be removing unreachable cases.

Sorry, I wasn't clear enough in my last email but everything related to
v2, v3 etc should be after "---" line. I fixed this in ath-next-test
branch and will apply your patch once kbuild has run it's tests.

-- 
Kalle Valo
