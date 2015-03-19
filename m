From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Revert "net: cx82310_eth: use common match macro"
Date: Wed, 18 Mar 2015 22:38:40 -0400 (EDT)
Message-ID: <20150318.223840.2031144211289934113.davem@davemloft.net>
References: <1426716061-20953-1-git-send-email-linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bjorn@mork.no, linux-kernel@vger.kernel.org
To: linux@rainbow-software.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1426716061-20953-1-git-send-email-linux@rainbow-software.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ondrej Zary <linux@rainbow-software.org>
Date: Wed, 18 Mar 2015 23:01:01 +0100

> This reverts commit 11ad714b98f6d9ca0067568442afe3e70eb94845 because
> it breaks cx82310_eth.
> 
> The custom USB_DEVICE_CLASS macro matches
> bDeviceClass, bDeviceSubClass and bDeviceProtocol
> but the common USB_DEVICE_AND_INTERFACE_INFO matches
> bInterfaceClass, bInterfaceSubClass and bInterfaceProtocol instead, which are
> not specified.
> 
> Signed-off-by: Ondrej Zary <linux@rainbow-software.org>

Applied, thank you.
