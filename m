From: David Miller <davem@davemloft.net>
Subject: Re: How to use gretap with bridge?
Date: Fri, 30 Oct 2009 12:27:26 -0700 (PDT)
Message-ID: <20091030.122726.194308238.davem@davemloft.net>
References: <846C5B546E47494CBBD796CA8CA1617EA3B43C@MST-VMAIL1.srv.mst.edu>
	<20091030155148.GA8283@gondor.apana.org.au>
	<20091030093957.7128c596@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, nneul@mst.edu, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52358
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932167AbZJ3T1C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 15:27:02 -0400
In-Reply-To: <20091030093957.7128c596@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 30 Oct 2009 09:39:57 -0700

> On Fri, 30 Oct 2009 11:51:48 -0400
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
>> gre: Fix dev_addr clobbering for gretap
>> 
>> Nathan Neulinger noticed that gretap devices get their MAC address
>> from the local IP address, which results in invalid MAC addresses
>> half of the time.
>> 
>> This is because gretap is still using the tunnel netdev ops rather
>> than the correct tap netdev ops struct.
>> 
>> This patch also fixes changelink to not clobber the MAC address
>> for the gretap case.
>> 
>> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>> 
>> Thanks,
> 
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>

Applied to net-2.6, thanks!
