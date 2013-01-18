From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: calxedaxgmac: throw away overrun frames
Date: Fri, 18 Jan 2013 14:15:06 -0500 (EST)
Message-ID: <20130118.141506.2118336604190817703.davem@davemloft.net>
References: <1358379397-7152-1-git-send-email-robherring2@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rob.herring@calxeda.com,
	linux-kernel@vger.kernel.org
To: robherring2@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358379397-7152-1-git-send-email-robherring2@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rob Herring <robherring2@gmail.com>
Date: Wed, 16 Jan 2013 17:36:37 -0600

> From: Rob Herring <rob.herring@calxeda.com>
> 
> The xgmac driver assumes 1 frame per descriptor. If a frame larger than
> the descriptor's buffer size is received, the frame will spill over into
> the next descriptor. So check for received frames that span more than one
> descriptor and discard them. This prevents a crash if we receive erroneous
> large packets.
> 
> Signed-off-by: Rob Herring <rob.herring@calxeda.com>

Applied.
