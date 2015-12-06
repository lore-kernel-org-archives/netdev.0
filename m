From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: qca_spi: fix transmit queue timeout handling
Date: Sun, 06 Dec 2015 12:03:02 -0500 (EST)
Message-ID: <20151206.120302.2006082903411506223.davem@davemloft.net>
References: <1449242950-19291-1-git-send-email-stefan.wahren@i2se.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
To: stefan.wahren@i2se.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1449242950-19291-1-git-send-email-stefan.wahren@i2se.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stefan Wahren <stefan.wahren@i2se.com>
Date: Fri,  4 Dec 2015 16:29:10 +0100

> In case of a tx queue timeout every transmit is blocked until the
> QCA7000 resets himself and triggers a sync which makes the driver
> flushs the tx ring. So avoid this blocking situation by triggering
> the sync immediately after the timeout. Waking the queue doesn't
> make sense in this situation.
> 
> Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
> Fixes: 291ab06ecf67 ("net: qualcomm: new Ethernet over SPI driver for QCA7000")

Applied and queued up for -stable.
