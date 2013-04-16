From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] hyperv: Fix a compiler warning in netvsc_send()
Date: Tue, 16 Apr 2013 15:49:12 -0400 (EDT)
Message-ID: <20130416.154912.896506198616355113.davem@davemloft.net>
References: <1366139031-12518-1-git-send-email-haiyangz@microsoft.com>
	<20130416.151141.1928940532005718606.davem@davemloft.net>
	<57e8f99081a94575a57cae5e93705c22@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kys@microsoft.com, olaf@aepfle.de,
	jasowang@redhat.com, linux-kernel@vger.kernel.org,
	devel@linuxdriverproject.org
To: haiyangz@microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <57e8f99081a94575a57cae5e93705c22@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Tue, 16 Apr 2013 19:34:52 +0000

> The Hyper-V hosts always use 64 bit request id. The guests can have
> 32 or 64 bit pointers which equal to the ulong type size. So we cast
> it to ulong type. And, assigning 32bit integer to 64 bit variable
> works fine.

It works fine, but it's unclean.

Keep the req_id type as "u64", because that's what it is, a 64-bit request ID.
