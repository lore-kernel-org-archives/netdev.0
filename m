From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v3] Add support of Cavium Liquidio ethernet
 adapters
Date: Fri, 19 Dec 2014 12:53:48 -0800
Message-ID: <20141219125348.6cf140c8@urahara>
References: <feba8d6dd1904fc3936864ae332df6d8@CO2PR0701MB744.namprd07.prod.outlook.com>
	<1418959519-31681-1-git-send-email-rvatsavayi@caviumnetworks.com>
	<20141218232833.3e640164@urahara>
	<CO2PR07MB490962E1E05D146BFD67B66FE6B0@CO2PR07MB490.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Vatsavayi, Raghu" <Raghu.Vatsavayi@caviumnetworks.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Burla, Satananda" <Satananda.Burla@caviumnetworks.com>,
	"Manlunas, Felix" <Felix.Manlunas@caviumnetworks.com>
To: "Chickles, Derek" <Derek.Chickles@caviumnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:56859 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751384AbaLSUx7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2014 15:53:59 -0500
Received: by mail-pa0-f41.google.com with SMTP id rd3so1904612pab.14
        for <netdev@vger.kernel.org>; Fri, 19 Dec 2014 12:53:59 -0800 (PST)
In-Reply-To: <CO2PR07MB490962E1E05D146BFD67B66FE6B0@CO2PR07MB490.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 19 Dec 2014 18:39:44 +0000
"Chickles, Derek" <Derek.Chickles@caviumnetworks.com> wrote:

> > Also, why does this device not have standard ethernet naming?  
> 
> No good reason. We will follow the p<slot_number>p<port_number> convention.

Use alloc_etherdev_mq and let it choose.
Policy about slot/port is done in userspace (udev/systemd).
