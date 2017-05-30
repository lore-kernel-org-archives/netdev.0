From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] net: ndisc.c: reduce size of
 __ndisc_fill_addr_option()
Date: Mon, 29 May 2017 20:41:06 -0700
Message-ID: <1496115666.2618.9.camel@perches.com>
References: <1495836052-8377-1-git-send-email-cugyly@163.com>
         <20170529.233009.1607319852930338432.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsahern@gmail.com,
        Linyu.Yuan@alcatel-sbell.com.cn
To: David Miller <davem@davemloft.net>, cugyly@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0076.hostedemail.com ([216.40.44.76]:38301 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750758AbdE3DlJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 May 2017 23:41:09 -0400
In-Reply-To: <20170529.233009.1607319852930338432.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-05-29 at 23:30 -0400, David Miller wrote:
> From: yuan linyu <cugyly@163.com>
> Date: Sat, 27 May 2017 06:00:52 +0800
> 
> > From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
> > 
> > Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
> 
> Applied, thanks.

OK, but is it really safe though?

Could "space" (an int) ever be negative after
subtracting "pad" and "data_len"?
