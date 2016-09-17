From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: fix SSN comparision
Date: Sat, 17 Sep 2016 10:00:52 -0400 (EDT)
Message-ID: <20160917.100052.67659156559031070.davem@davemloft.net>
References: <9f22e4725d836feda1b2c2483303adb30838216f.1473962178.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        nhorman@tuxdriver.com, vyasevich@gmail.com
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60124 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751269AbcIQOAz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2016 10:00:55 -0400
In-Reply-To: <9f22e4725d836feda1b2c2483303adb30838216f.1473962178.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Thu, 15 Sep 2016 15:02:38 -0300

> This function actually operates on u32 yet its paramteres were declared
> as u16, causing integer truncation upon calling.
> 
> Note in patch context that ADDIP_SERIAL_SIGN_BIT is already 32 bits.
> 
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Applied.
