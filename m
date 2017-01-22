From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: mvneta: implement .set_wol and .get_wol
Date: Sun, 22 Jan 2017 17:49:35 +0100
Message-ID: <20170122164935.GA26560@lunn.ch>
References: <1485079590-6392-1-git-send-email-houjingj@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, thomas.petazzoni@free-electrons.com,
        netdev@vger.kernel.org
To: Jingju Hou <houjingj@marvell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41017 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750999AbdAVQtm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 22 Jan 2017 11:49:42 -0500
Content-Disposition: inline
In-Reply-To: <1485079590-6392-1-git-send-email-houjingj@marvell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 22, 2017 at 06:06:30PM +0800, Jingju Hou wrote:
> Signed-off-by: Jingju Hou <houjingj@marvell.com>

Hi Jingju

Please include a real comment here. Something like:

The mvneta itself does not support WOL, but the PHY might. So pass the
calls to the PHY.

It also looks like you are patching an old kernel. Network patches
like this need to be against net-next. You should also include
net-next in the subject line.

Thanks
	Andrew
