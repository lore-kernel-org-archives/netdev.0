From: Mark Lord <mlord@pobox.com>
Subject: Re: [PATCH net 1/2] r8152: fix the sw rx checksum is unavailable
Date: Fri, 25 Nov 2016 08:32:23 -0500
Message-ID: <d31b744e-365e-6ef5-876a-fe64496dd1de@pobox.com>
References: <0835B3720019904CB8F7AA43166CEEB201055ED8@RTITMBSV03.realtek.com.tw>
 <20161124.112152.692025478489876693.davem@davemloft.net>
 <23e0c132-8844-0a34-3e0b-e412f76493ba@pobox.com>
 <20161124.121140.2054576632424977475.davem@davemloft.net>
 <c3ca9e10-64de-2454-b99a-19e8302f5c12@pobox.com>
 <20161124190055.GA3642@kroah.com>
 <9e8ff5b4-1c72-3106-7821-73484de133c2@pobox.com>
 <0835B3720019904CB8F7AA43166CEEB20105653D@RTITMBSV03.realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        nic_swsd <nic_swsd@realtek.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: Hayes Wang <hayeswang@realtek.com>, Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pb-sasl2.pobox.com ([64.147.108.67]:62272 "EHLO
        sasl.smtp.pobox.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754060AbcKYNc1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 08:32:27 -0500
In-Reply-To: <0835B3720019904CB8F7AA43166CEEB20105653D@RTITMBSV03.realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-11-25 04:52 AM, Hayes Wang wrote:
..
> What is the value of /sys/bus/usb/devices/.../power/control ?

That entry does not exist -- power control is completely
disabled on this board.

Good try, though -- USB power control still causes me trouble
on PCs with mice and remote controls.  But not here.
