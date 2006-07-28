From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCHv2 2.6.18-rc1-mm2 1/3] net: UDP-Lite generic support
Date: Fri, 28 Jul 2006 09:19:55 +0100
Message-ID: <200607280919.55482@strip-the-willow>
References: <200607141719.02766@strip-the-willow> <20060727.223010.63131639.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, yoshfuji@linux-ipv6.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, kaber@coreworks.de, pekkas@netcore.fi,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:10884 "EHLO erg.abdn.ac.uk")
	by vger.kernel.org with ESMTP id S932585AbWG1IVJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2006 04:21:09 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060727.223010.63131639.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

thank you very much for taking time to revise the code 
and for the detailed comments.


|  The amount of code duplication is absolutely enormous and
|  totally unnecessary.
You are right. 
So far I thought it better to keep UDP and UDP-Lite separate but an
intelligent code integration does seem the better way.


<snip>
|  It's mostly clerical work, but it will mean that we will have one
|  copy of all this code and as a result we won't even need a config
|  option for UDP-Lite.

I will start with the v4-side and post a small RFC patch to see whether
I got the concepts right. (Due to vacation, this will not before mid/end 
of August.)



Best regards
Gerrit
