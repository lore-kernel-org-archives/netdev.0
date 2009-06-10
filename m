From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 6/8] qlge: Add support for varied pcie
 function numbers.
Date: Wed, 10 Jun 2009 01:05:52 -0700 (PDT)
Message-ID: <20090610.010552.87443041.davem@davemloft.net>
References: <1244561974-25662-1-git-send-email-ron.mercer@qlogic.com>
	<1244561974-25662-6-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51032
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756005AbZFJIFu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 04:05:50 -0400
In-Reply-To: <1244561974-25662-6-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ron Mercer <ron.mercer@qlogic.com>
Date: Tue,  9 Jun 2009 08:39:32 -0700

> Currently we support only PCIe NIC functions zero and one, and FCoE
> functions as 3 and 4. Future configurations can mix these up in any
> fashion.
> This patch removes the 0-1 dependancy and allows usage of any of the 4
> functions. We also find the alternate NIC function (if exist) and
> determine our port number based on the comparison of the two functions:
> Lower function number gets first port, higher function gets second port.
> 
> Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>

Applied.
