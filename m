From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net 0/3] mlx4 fixes
Date: Thu, 13 Mar 2014 13:10:38 +0200
Message-ID: <5321922E.4020306@mellanox.com>
References: <1394637392-31104-1-git-send-email-ogerlitz@mellanox.com> <20140312.161408.2149985285610209.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <amirv@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:51532 "EHLO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753574AbaCMLKn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2014 07:10:43 -0400
In-Reply-To: <20140312.161408.2149985285610209.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/03/2014 22:14, David Miller wrote:
> I wonder though, if a MAC address change results in a VLAN steering
> rule insertion failure, won't we be left in an inconsistent state?

So eventually when mlx4_en_replace_mac()  returns with error, there is a 
printout, so users
will at least be notified that something went wrong.

Or.
