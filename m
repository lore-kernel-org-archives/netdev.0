From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] xen/netfront: improve truesize tracking
Date: Fri, 21 Dec 2012 10:33:43 -0800
Message-ID: <50D4AB87.8050601@hp.com>
References: <1355838711-5473-1-git-send-email-ian.campbell@citrix.com> <1355843525.9380.18.camel@edumazet-glaptop> <1355844398.14620.254.camel@zakaz.uk.xensource.com> <55633610.20121219123427@eikelenboom.it> <1355933869.21834.13.camel@edumazet-glaptop> <1797374383.20121220135139@eikelenboom.it> <1356017968.21834.2859.camel@edumazet-glaptop> <1609010645.20121221122100@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <erdnetdev@gmail.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	annie li <annie.li@oracle.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>
To: Sander Eikelenboom <linux@eikelenboom.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:20150 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751949Ab2LUSdq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2012 13:33:46 -0500
In-Reply-To: <1609010645.20121221122100@eikelenboom.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm guessing that trusize checks matter more on the "inbound" path than 
the outbound path?  If that is indeed the case, then instead of, or in 
addition to using the -s option to set the local (netperf side) socket 
buffer size, you should use a -S option to set the remote (netserver 
side) socket buffer size.

happy benchmarking,

rick jones
