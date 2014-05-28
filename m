From: Andreas Schwab <schwab@linux-m68k.org>
Subject: Re: [PATCH] mvme147: use correct order of ram pages
Date: Wed, 28 May 2014 11:39:20 +0200
Message-ID: <mvmvbsqjl87.fsf@hawking.suse.de>
References: <1401250073-16603-1-git-send-email-akong@redhat.com>
	<CAMuHMdV-g35ijLgcE=sSM3eE+fCxC1WOiAX2PaWs0z4-+bDP+A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Amos Kong <akong@redhat.com>,
	"Linux\/m68k" <linux-m68k@vger.kernel.org>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdV-g35ijLgcE=sSM3eE+fCxC1WOiAX2PaWs0z4-+bDP+A@mail.gmail.com>
	(Geert Uytterhoeven's message of "Wed, 28 May 2014 09:51:39 +0200")
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Geert Uytterhoeven <geert@linux-m68k.org> writes:

>> -/* We have 16834 bytes of RAM for the init block and buffers. This places
>> +/* We have 16384 bytes of RAM for the init block and buffers. This places
>>   * an upper limit on the number of buffers we can use. NetBSD uses 8 Rx
>>   * buffers and 2 Tx buffers.
>>   */
>> +#define M147LANCE_RAM_SIZE   16384 /* 16K */
>>  #define LANCE_LOG_TX_BUFFERS 1
>>  #define LANCE_LOG_RX_BUFFERS 3
>
> BTW,I also find it fishy why the driver uses only 1+3 buffers, since more
> RAM is available.

It's 2^1+2^3.

Andreas.

-- 
Andreas Schwab, schwab@linux-m68k.org
GPG Key fingerprint = 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
