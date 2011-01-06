From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH] UDPCP Communication Protocol
Date: Thu, 6 Jan 2011 21:11:00 +0100
Message-ID: <20110106201100.GA3582@ucw.cz>
References: <1293787785-3834-1-git-send-email-stefani@seibold.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org
To: stefani@seibold.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1293787785-3834-1-git-send-email-stefani@seibold.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

> UDPCP is a communication protocol specified by the Open Base Station
> Architecture Initiative Special Interest Group (OBSAI SIG). The
> protocol is based on UDP and is designed to meet the needs of "Mobile
> Communcation Base Station" internal communications. It is widely used by
> the major networks infrastructure supplier.

Why does it need to be in kernel?

> +struct udpcp_statistics {
> +	unsigned int txMsgs;		/* Num of transmitted messages */
> +	unsigned int rxMsgs;		/* Num of received messages */
> +	unsigned int txNodes;		/* Num of receiver nodes */
> +	unsigned int rxNodes;		/* Num of transmitter nodes */
> +	unsigned int txTimeout;		/* Num of unsuccessful transmissions */
> +	unsigned int rxTimeout;		/* Num of partial message receptions */
> +	unsigned int txRetries;		/* Num of resends */
> +	unsigned int rxDiscardedFrags;	/* Num of discarded fragments */
> +	unsigned int crcErrors;		/* Num of crc errors detected */
> +};
 
AvoidCamelCase.
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
