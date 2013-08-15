From: Libo Chen <clbchenlibo.chen@huawei.com>
Subject: Re: [PATCH RESEND 1/8] net: fsl_pq_mdio: use platform_{get,set}_drvdata()
Date: Thu, 15 Aug 2013 17:27:40 +0800
Message-ID: <520C9F0C.6040303@huawei.com>
References: <5208E215.6030007@huawei.com> <520AFBEE.7030903@huawei.com> <520BD275.5060004@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Li Zefan <lizefan@huawei.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <520BD275.5060004@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2013/8/15 2:54, Sergei Shtylyov wrote:
> Hello.
> 
> On 08/14/2013 07:39 AM, Libo Chen wrote:
> 
>> We can use the wrapper functions platform_{get,set}_drvdata() instead of
>> dev_{get,set}_drvdata() with &pdev->dev, it is convenient for user.
> 
>> Also, unnecessary dev_set_drvdata() is removed, because the driver core
>> clears the driver data to NULL after device_release or on probe failure.
> 
>    You misunderstood. That's a material for 2 separate patch sets (or maybe single patches, since multiple files can be collapsed in a single patch).
> 

 okay, thanks.


Libo

>> Signed-off-by: Libo Chen <libo.chen@huawei.com>
> 
> WBR, Sergei
> 
> 
> 
