From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH wireless-dev] add p54 driver
Date: Tue, 17 Oct 2006 11:43:48 -0400
Message-ID: <1161099828.5668.7.camel@localhost.localdomain>
References: <200610171105.34912.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:59571 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1751148AbWJQPlg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2006 11:41:36 -0400
To: Michael Wu <flamingice@sourmilk.net>
In-Reply-To: <200610171105.34912.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-10-17 at 11:05 -0400, Michael Wu wrote:
> (originally sent to John Linville, forgot to CC netdev..)
> 
> Hi,
> 
> The attached patch adds support for 3887 based prism54 usb wireless adaptors. 
> It is partially based on the islsm driver by Jean-Baptiste Note, but most of 
> the code is new (and uses d80211 instead of madwifi). It doesn't work 
> perfectly yet, but it can connect to an unsecure AP and send/receive packets 
> as long as you don't hit the tx code too hard. Further hardware support for 
> pci and net2280 usb will follow later. Also, I am unable to make it crash. 
> Thus, it should be in a suitable state for other developers to hack on.

I'm assuming this is for the softmac prism54 chipset, right?

Dan

> Thanks,
> -Michael Wu

