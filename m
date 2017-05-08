From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v4 net-next 04/10] net/ncsi: Ethtool operation to get
 NCSI topology
Date: Mon, 8 May 2017 12:40:28 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFFE7192@AcuExch.aculab.com>
References: <1493786681-27468-1-git-send-email-gwshan@linux.vnet.ibm.com>
 <1493786681-27468-5-git-send-email-gwshan@linux.vnet.ibm.com>
 <20170503221944.1dd0d576@xeon-e3> <20170504061559.GA2162@gwshan>
 <063D6719AE5E284EB5DD2968C1650D6DCFFE535E@AcuExch.aculab.com>
 <20170508001955.GA5787@gwshan>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "joe@perches.com" <joe@perches.com>,
        "kubakici@wp.pl" <kubakici@wp.pl>,
        "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        "davem@davemloft.net" <davem@davemloft.net>
To: 'Gavin Shan' <gwshan@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.183]:64564 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750853AbdEHMkh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 08:40:37 -0400
In-Reply-To: <20170508001955.GA5787@gwshan>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gavin Shan
> Sent: 08 May 2017 01:20
...
> >Why 16 bits?
> >You are just making life hard for the compiler and possibly generating
> >random padding.
> >
> 
> It's because there are 256 NCSI channels to maximal degree. So 16-bits
> is the minial data width to hold it in signed format. Yes, I think
> __s32 would be better in this case. However, I would like to discard
> the negotiation mechanism in next respin.

Just because the domain of a value fits in 16 bits doesn't mean
that a 16bit type is appropriate.

It is generally much better to use 32 (aka machine word) sized
items unless you have an array or are trying to fit a lot of
items into a small memory area.

	David
