From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv4 net-next 3/5] sctp: implement sender-side procedures
 for SSN/TSN Reset Request Parameter
Date: Fri, 20 Jan 2017 14:00:34 -0500 (EST)
Message-ID: <20170120.140034.1018095629148946810.davem@davemloft.net>
References: <cover.1484934853.git.lucien.xin@gmail.com>
        <ae54d06e442d8fba6a5983fb81fb4c8ae4bee3ef.1484934853.git.lucien.xin@gmail.com>
        <20170120182521.GV3781@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lucien.xin@gmail.com, netdev@vger.kernel.org,
        linux-sctp@vger.kernel.org, nhorman@tuxdriver.com,
        vyasevich@gmail.com
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36222 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751497AbdATTKv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 14:10:51 -0500
In-Reply-To: <20170120182521.GV3781@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Fri, 20 Jan 2017 16:25:22 -0200

> I talked offline with Xin about this and we cannot do it this way.
> Unfortunatelly we will have to take the long road here, because then
> we may send data while sending the request, as the streams are not
> closed yet.  We really need to close team, send the request, and
> re-open if the send fails.

I am expecting another spin of this series, correct?
