From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v5 0/2] Multicast group join/leave at ip level
Date: Mon, 2 Mar 2015 12:43:04 +0000
Message-ID: <20150302124304.GA3339@casper.infradead.org>
References: <1424887115-3483-1-git-send-email-challa@noironetworks.com>
 <20150227.162611.864498157750734820.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: challa@noironetworks.com, eric.dumazet@gmail.com,
	daniel@iogearbox.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:48684 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750966AbbCBMnH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 07:43:07 -0500
Content-Disposition: inline
In-Reply-To: <20150227.162611.864498157750734820.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/27/15 at 04:26pm, David Miller wrote:
> Applied, but I'm wondering how many hacks we are going to add to the
> tree simply because openvswitch does all of it's stuff with non-native
> tunneling devices...

I hope Jiri's proposed named tunnel socket concept will close the
current scalability gap and allow to merge the paths together again.
