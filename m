From: Ben Greear <greearb@candelatech.com>
Subject: Re: IPv6 FIB related crash with MACVLANs in 3.9.11+ kernel.
Date: Mon, 29 Sep 2014 11:44:22 -0700
Message-ID: <5429A886.1040809@candelatech.com>
References: <52EFFE20.5080500@candelatech.com> <20140203220323.GB17999@order.stressinduktion.org> <52F012FF.9030105@candelatech.com> <52F65EB4.1050306@candelatech.com> <20140208172310.GF16198@order.stressinduktion.org> <loom.20140926T001736-777@post.gmane.org> <1411906297.2400343.172598909.66223582@webmail.messagingengine.com> <loom.20140929T195637-887@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hongmei Li <duckcncn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:51722 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753898AbaI2SoX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 14:44:23 -0400
In-Reply-To: <loom.20140929T195637-887@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/29/2014 11:15 AM, Hongmei Li wrote:
> Thanks Hannes for your prompt response!
> 
> We just encountered this issue two times in our product stability test so far,
> and my panic backtrace is the exactly same with the one reported here.
> I don't know how to reproduce the issue till now. 
> I tried several method, unfortunately, I can not reproduce it by myself. :(

We could reproduce it easily using our user-space tool that creates 1000
mac-vlans, configures them, dumps routing tables, etc.  But, we could
only reproduce it when we had the ixgbe ports unplugged.  If they
were properly connected to a switch, we did not see any crashes.

My original email on 2/3/2014 has more details, and the thread that
follows has some info on debugging we did at the time.

We will be happy to test patches...

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
