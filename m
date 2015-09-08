From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] device property: Don't overwrite addr when failing in
 device_get_mac_address
Date: Tue, 08 Sep 2015 13:40:39 -0700 (PDT)
Message-ID: <20150908.134039.343467168113066960.davem@davemloft.net>
References: <1441321190-25631-1-git-send-email-julien.grall@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeremy.linton@arm.com, linux-kernel@vger.kernel.org,
	gregkh@linuxfoundation.org, netdev@vger.kernel.org
To: julien.grall@citrix.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1441321190-25631-1-git-send-email-julien.grall@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julien Grall <julien.grall@citrix.com>
Date: Thu, 3 Sep 2015 23:59:50 +0100

> The function device_get_mac_address is trying different property names
> in order to get the mac address. To check the return value, the variable
> addr (which contain the buffer pass by the caller) will be re-used. This
> means that if the previous property is not found, the next property will
> be read using a NULL buffer.
> 
> Therefore it's only possible to retrieve the mac if node contains a
> property "mac-address". Fix it by using a temporary buffer for the
> return value.
> 
> This has been introduced by commit 4c96b7dc0d393f12c17e0d81db15aa4a820a6ab3
> "Add a matching set of device_ functions for determining mac/phy"
> 
> Signed-off-by: Julien Grall <julien.grall@citrix.com>

Applied, thanks.
