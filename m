From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [PATCH 2.6.21 2/4] cxgb3 - Auto-load FW if mismatch detected
Date: Wed, 21 Mar 2007 18:02:45 -0800
Message-ID: <4601E3C5.5070103@chelsio.com>
References: <20070318201006.16292.12877.stgit@localhost.localdomain> <20070321150706.9b916d79.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, swise@opengridcomputing.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753132AbXCVCDI@vger.kernel.org>
In-Reply-To: <20070321150706.9b916d79.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> On Sun, 18 Mar 2007 13:10:06 -0700
> divy@chelsio.com wrote:
>
>   
>>  config CHELSIO_T3
>>          tristate "Chelsio Communications T3 10Gb Ethernet support"
>>          depends on PCI
>> +	select FW_LOADER
>>     
>
> Something has gone wrong with the indenting there.
>   

The added line is fine. The surrounding lines are not. They use white 
spaces.
I'll send a patch over the last series to use tabs in drivers/net/Kconfig.

Cheers,
Divy
