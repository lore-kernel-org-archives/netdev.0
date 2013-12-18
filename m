From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] dm9601: work around tx fifo sync issue on dm962x
Date: Wed, 18 Dec 2013 17:48:01 -0500 (EST)
Message-ID: <20131218.174801.1302082781180839324.davem@davemloft.net>
References: <1387190135-17052-1-git-send-email-peter@korsgaard.com>
	<1387190135-17052-5-git-send-email-peter@korsgaard.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joseph_chang@davicom.com.tw,
	stable@vger.kernel.org
To: peter@korsgaard.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1387190135-17052-5-git-send-email-peter@korsgaard.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter Korsgaard <peter@korsgaard.com>
Date: Mon, 16 Dec 2013 11:35:35 +0100

> Certain dm962x revisions contain an bug, where if a USB bulk transfer retry
> (E.G. if bulk crc mismatch) happens right after a transfer with odd or
> maxpacket length, the internal tx hardware fifo gets out of sync causing
> the interface to stop working.
> 
> Work around it by adding up to 3 bytes of padding to ensure this situation
> cannot trigger.
> 
> This workaround also means we never pass multiple-of-maxpacket size skb's
> to usbnet, so the length adjustment to handle usbnet's padding of those can
> be removed.
> 
> Cc: <stable@vger.kernel.org>
> Reported-by: Joseph Chang <joseph_chang@davicom.com.tw>
> Signed-off-by: Peter Korsgaard <peter@korsgaard.com>

Applied.
