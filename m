From: Erik Hugne <erik.hugne@ericsson.com>
Subject: Re: [IPv6] interface-local multicast escapes the local node
Date: Thu, 7 Feb 2013 08:28:57 +0100
Message-ID: <20130207072857.GA27969@eerihug-hybrid.ki.sw.ericsson.se>
References: <20130206084949.GA11193@eerihug-hybrid.ki.sw.ericsson.se>
 <20130206121248.GC10290@order.stressinduktion.org>
 <20130206130739.GA1305@eerihug-hybrid.ki.sw.ericsson.se>
 <20130206134950.GD10290@order.stressinduktion.org>
 <51127781.2000504@linux-ipv6.org>
 <20130206160409.GB18040@order.stressinduktion.org>
 <51128985.2010701@linux-ipv6.org>
 <20130207010010.GD19537@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw7.ericsson.se ([193.180.251.48]:65244 "EHLO
	mailgw7.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751402Ab3BGHby (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2013 02:31:54 -0500
Content-Disposition: inline
In-Reply-To: <20130207010010.GD19537@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 07, 2013 at 02:00:10AM +0100, Hannes Frederic Sowa wrote:
> RFC4541 3. IPv6 Considerations:
> 
>    MLD messages are also not sent regarding groups with addresses in the
>    range FF00::/15 (which encompasses both the reserved FF00::/16 and
>    node-local FF01::/16 IPv6 address spaces).  These addresses should
>    never appear in packets on the link.
> 
> It gives a strong indication that we should drop these packets. What do you
> think?

That was my understanding aswell. I asked for some clarifications on the ietf list:
    <quote>
    > The key is that the packets should be dropped without generating
    > any errors or traffic.
    Yep, you are right - I assumed that implicitly, but
    I should have mentioned that explicitly :-)
    </quote>
http://www.ietf.org/mail-archive/web/ipv6/current/msg17126.html

//E 
