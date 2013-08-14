From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH RESEND 0/8] use platform_{get,set}_drvdata()
Date: Wed, 14 Aug 2013 22:56:35 +0400
Message-ID: <520BD2E3.9080606@cogentembedded.com>
References: <5208E20A.4010306@huawei.com> <520AFB3F.2090006@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	Li Zefan <lizefan@huawei.com>, leoli@freescale.com,
	linuxppc-dev@lists.ozlabs.org, pantelis.antoniou@gmail.com,
	vbordug@ru.mvista.com, Greg KH <gregkh@linuxfoundation.org>,
	jg1.han@samsung.com
To: Libo Chen <clbchenlibo.chen@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <520AFB3F.2090006@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/14/2013 07:36 AM, Libo Chen wrote:

> We can use the wrapper functions platform_{get,set}_drvdata() instead of
> dev_{get,set}_drvdata() with &pdev->dev, it is convenient for user.
>
> Also, unnecessary dev_set_drvdata() is removed, because the driver core
> clears the driver data to NULL after device_release or on probe failure.

    Saying "also" in the changelog is usually a good sign that the patch 
should be split.

WBR, Sergei
