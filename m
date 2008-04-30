From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: 2.6.25-git16 fails with "undefined reference to	`compat_mc_getsockopt'"
Date: Wed, 30 Apr 2008 23:11:39 +0200
Message-ID: <4818E08B.4040901@hartkopp.net>
References: <20080430204622.GA1663@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Pavel Emelyanov <xemul@openvz.org>
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:34716 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759834AbYD3VWn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2008 17:22:43 -0400
In-Reply-To: <20080430204622.GA1663@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greg KH wrote:
> Don't know if you have seen this or not, but 2.6.25-gi16 seems to fail
> with:
> 	net/built-in.o: In function `ipv6_getsockopt':
> 	(.text+0x6829c): undefined reference to `compat_mc_getsockopt'
>
> I've attached my .config below if that helps any.
>
> thanks,
>
> greg k-h
>   

Hi Greg,

this issue has been already identified and fixed by Pavel Emelyanov:

http://marc.info/?l=linux-netdev&m=120956601217678&w=2

I also had this problem and his fix worked fine for me.

Regards,
Oliver
