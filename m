From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH] bgmac: Clean warning messages
Date: Sat, 7 Mar 2015 11:59:11 +0100
Message-ID: <CACna6rw8u4aZ4FLuBQ78i8ef4JCw+jFbSO6x3upLzgGxVwoPDw@mail.gmail.com>
References: <1425725518-30651-1-git-send-email-peter.senna@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	w-lkml@lebenslange-mailadresse.de, Joe Perches <joe@perches.com>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Peter Senna Tschudin <peter.senna@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425725518-30651-1-git-send-email-peter.senna@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7 March 2015 at 11:51, Peter Senna Tschudin <peter.senna@gmail.com> wrote:
> On my test environment the throughput of a file transfer drops
> from 4.4MBps to 116KBps due the number of repeated warning
> messages. This patch removes the warning messages.

This sounds like you're removing these warnings just because they are
lowering your throughput.

Please update your commit message to make it clear there are not
needed (because DMA works correctly with addresses using 0xC0000000
bits).
