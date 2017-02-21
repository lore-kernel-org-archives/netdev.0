From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [net-next][PATCH] RDS: keep data type consistent in the user
 visible header
Date: Tue, 21 Feb 2017 14:29:33 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFE6CA26@AcuExch.aculab.com>
References: <1487387747-5324-1-git-send-email-santosh.shilimkar@oracle.com>
        <20170220.101951.663166903772216217.davem@davemloft.net>
        <20170220153722.GB16561@oracle.com>
 <20170220.103912.194197218422769191.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "santosh.shilimkar@oracle.com" <santosh.shilimkar@oracle.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: 'David Miller' <davem@davemloft.net>,
        "sowmini.varadhan@oracle.com" <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.187]:55731 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752569AbdBUO37 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 09:29:59 -0500
In-Reply-To: <20170220.103912.194197218422769191.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The entire file should use the proper "__uX" kernel types
> rather than the uint* ones.

The uint* ones are part of the C standard :-)

	David
