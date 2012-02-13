From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [patch net-next] cxgb3: update firmware version
Date: Mon, 13 Feb 2012 13:39:15 -0800
Message-ID: <4F398303.1030606@chelsio.com>
References: <20120213202846.631.30806.stgit@speedy5.asicdesigners.com> <1329165817.2092.62.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Steve Wise <swise@opengridcomputing.com>, nhorman@tuxdriver.com
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1329165817.2092.62.camel@shinybook.infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday, February 13, 2012 12:43:37 PM, David Woodhouse wrote:
>
> On Mon, 2012-02-13 at 12:28 -0800, Divy Le Ray wrote:
>>
>> This patch updates the firmware version cxgb3 is requesting to 7.12.0.
>
>
> I'm confused. Your patch doesn't change anything in the driver, except
> the firmware version. So why is it a "major" change?

Hi David,

cxgb3 embeds the firmware file name it will request at load time.
It uses the FW_VERSION_* defs to construct the firmware name FW_FNAME 
before calling request_firmware().
Hence the need to update the firmware minor version.

On the other hand, the driver version update is not a strict requirement 
here.
I would prefer keeping it though.

Cheers,
Divy
