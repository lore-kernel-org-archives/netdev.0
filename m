From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] usb: cdc-ncm: Increase maximum allowed datagram
 size
Date: Tue, 14 Feb 2012 14:46:22 -0500 (EST)
Message-ID: <20120214.144622.678577766818888054.davem@davemloft.net>
References: <1329230375-25508-1-git-send-email-toby.gray@realvnc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oliver@neukum.name, gregkh@linuxfoundation.org,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: toby.gray@realvnc.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1329230375-25508-1-git-send-email-toby.gray@realvnc.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Toby Gray <toby.gray@realvnc.com>
Date: Tue, 14 Feb 2012 14:39:35 +0000

> Some NCM devices exist which will send datagrams larger than 2k and
> don't support the GetMaxDatagramSize request, such as the Nokia 701
> Mobile Telephone.
> 
> This sets the maximum limit of datagrams to the theoretical limit for
> 16-bit NTBs, preventing dropping of large datagrams received from some
> devices.
> 
> Signed-off-by: Toby Gray <toby.gray@realvnc.com>

Can a USB expert please sanity check this before I apply it?

Thanks.
