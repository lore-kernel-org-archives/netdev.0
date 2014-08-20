From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: [PATCH net-next 4/4] r8152: support firmware files
Date: Wed, 20 Aug 2014 12:35:09 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB251585A@RTITMBSV03.realtek.com.tw>
References: <1394712342-15778-16-Taiwan-albertk@realtek.com>
	<1394712342-15778-20-Taiwan-albertk@realtek.com>
 <CAN_we7P2LDvR8miAsoSeL6+iEOK+ucgjRDC8jtPbc4_-2nn7MQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	nic_swsd <nic_swsd@realtek.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	USB list <linux-usb@vger.kernel.org>
To: Daniele Forsi <dforsi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:52403 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752385AbaHTMfQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2014 08:35:16 -0400
In-Reply-To: <CAN_we7P2LDvR8miAsoSeL6+iEOK+ucgjRDC8jtPbc4_-2nn7MQ@mail.gmail.com>
Content-Language: zh-TW
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Daniele Forsi [mailto:dforsi@gmail.com] 
> Sent: Wednesday, August 20, 2014 8:01 PM
> To: Hayes Wang
> Cc: netdev@vger.kernel.org; nic_swsd; 
> linux-kernel@vger.kernel.org; USB list
> Subject: Re: [PATCH net-next 4/4] r8152: support firmware files
[...]
> > +       start = le32_to_cpu(fw_header->fw_start);
> > +       if (start > fw->size)
> > +               goto out;
> 
> since "start" is an offset in an array of size "fw->size" this should
> check for ">=" and if a command is at least cmd(2 bytes) + length(2
> bytes), shouldn't this check for "start >= fw->size - 4"?

Is this necessary? Besides the check of the "start",
there are checks of the "size" and rtl_fw_data_ok().
I think they cover the situations which you indicate.
 
Best Regards,
Hayes
