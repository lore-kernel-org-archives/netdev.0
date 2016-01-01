From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net-libertas: Better exception handling in
 if_spi_host_to_card_worker()
Date: Sat, 2 Jan 2016 02:14:46 +0300
Message-ID: <56870866.7020000@cogentembedded.com>
References: <566ABCD9.1060404@users.sourceforge.net>
 <5686F0B2.5000000@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: SF Markus Elfring <elfring@users.sourceforge.net>,
	libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, Kalle Valo <kvalo@codeaurora.org>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <5686F0B2.5000000@users.sourceforge.net>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello

On 1/2/2016 12:33 AM, SF Markus Elfring wrote:

> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Fri, 1 Jan 2016 22:27:20 +0100
>
> This issue was detected by using the Coccinelle software.
>
> Move the jump label directly before the desired log statement
> so that the variable "err" will not be checked once more
> after it was determined that a function call failed.
> Use the identifier "report_failure" instead of the label "err".

    Why? The code was smart enough and you're making it uglier that it needs 
to be.

> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>

MBR, Sergei

