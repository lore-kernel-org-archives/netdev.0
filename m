From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] 8139too: Allow using the largest possible MTU
Date: Mon, 10 Nov 2014 15:30:29 -0500 (EST)
Message-ID: <20141110.153029.1477649870636665364.davem@davemloft.net>
References: <1415447316-12424-1-git-send-email-albeu@free.fr>
	<1415447316-12424-2-git-send-email-albeu@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	bhelgaas@google.com, benoit.taine@lip6.fr, ebiederm@xmission.com
To: albeu@free.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415447316-12424-2-git-send-email-albeu@free.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alban Bedel <albeu@free.fr>
Date: Sat,  8 Nov 2014 12:48:36 +0100

> This driver allows MTU up to 1518 bytes which is not enought to run
> batman-adv. Simply raise the maximum packet size up to the maximum
> allowed by the transmit descriptor, 1792 bytes, giving a maximum MTU
> of 1774 bytes.
> 
> Signed-off-by: Alban Bedel <albeu@free.fr>

Also applied to net-next, thanks.
