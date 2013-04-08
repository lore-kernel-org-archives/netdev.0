From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mrf24j40: Enable link-layer acknowledgement and retry
Date: Mon, 08 Apr 2013 12:09:43 -0400 (EDT)
Message-ID: <20130408.120943.2116357191148187259.davem@davemloft.net>
References: <1365194091-2542-1-git-send-email-alan@signal11.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: alan@signal11.us
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1365194091-2542-1-git-send-email-alan@signal11.us>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alan Ott <alan@signal11.us>
Date: Fri,  5 Apr 2013 16:34:51 -0400

> On the MRF24J40, link-layer acknowledgment request and retry must be
> turned on explicitly for each packet.  Turn this on in the hardware based
> on the FC_ACK_REQ bit being set in the packet.
> 
> Also, now that failure to receive an ACK will cause the hardware to report
> failure of transmission, change the log level for this failure to debug
> level.
> 
> Signed-off-by: Alan Ott <alan@signal11.us>

Applied.
