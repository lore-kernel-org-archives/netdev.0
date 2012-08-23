From: "Huang, Xiong" <xiong@qca.qualcomm.com>
Subject: RE: [PATCH v2] net: add new QCA alx ethernet driver
Date: Thu, 23 Aug 2012 06:35:40 +0000
Message-ID: <157393863283F442885425D2C45428562A4F5169@nasanexd02f.na.qualcomm.com>
References: <1345480949-14800-1-git-send-email-cjren@qca.qualcomm.com>
 <20120822.225700.714020017287504609.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	qca-linux-team <qca-linux-team@qualcomm.com>,
	nic-devel <nic-devel@qualcomm.com>,
	"Rodriguez, Luis" <rodrigue@qca.qualcomm.com>
To: David Miller <davem@davemloft.net>,
	"Ren, Cloud" <cjren@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:14263 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751133Ab2HWGfm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 02:35:42 -0400
In-Reply-To: <20120822.225700.714020017287504609.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> This is why we require that portable, sane, interfaces are added to ethtool for
> driver diagnostics.  That way users can perform a task in the same way
> regardless of what hardware and driver are underneath.

I quite agree you on using ethtool to implement it. we did consider it. 
But ethtool has some limitation, for example, the NIC has built-in OTP (TWSI interface)
And Flash (External SPI interface),  their properties are quite different with EEPROM which
Ethtool supports.
To support such memory (OTP/Flash), we need additional input parameters.

Same situation exists in diagnostic utility. Ethtool only provide two options : offline & online
That's too gross to locate which part/module of the chip is malfunction. we also need 
more options to detect it.

that's why we finally selected a custom debugfs interface. 

Thanks
Xiong
