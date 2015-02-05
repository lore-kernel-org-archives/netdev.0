From: Alban Browaeys <alban.browaeys@gmail.com>
Subject: "net: remove sock_iocb" breaks ip tool - "Cannot send dump request
 : Connection refused"
Date: Thu, 05 Feb 2015 10:36:01 +0100
Message-ID: <1423128961.5723.10.camel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Christoph Hellwig <hch@lst.de>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:42553 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756726AbbBEJgG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 04:36:06 -0500
Received: by mail-wi0-f171.google.com with SMTP id l15so37429326wiw.4
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 01:36:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"ip a" returns "Cannot send dump request : Connection refused" until I
revert commit 7cc05662682d ("net: remove sock_iocb").
This as root or as user.

NetworkManager is affected too.

Could siocb cache the cookie ? 


Best regards,
Alban
