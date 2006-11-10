From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH] IPv6: optimize echo reply checksum calculation
Date: Fri, 10 Nov 2006 14:04:32 -0500
Message-ID: <4554CD40.3030801@hp.com>
References: <20061108221332.GI29920@ftp.linux.org.uk> <45536622.90708@hp.com> <20061109.151402.15590179.davem@davemloft.net> <4554A811.5060402@hp.com> <20061110173422.GM29920@ftp.linux.org.uk> <4554BC17.8020809@hp.com> <20061110180534.GN29920@ftp.linux.org.uk> <20061110182031.GO29920@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:55010 "EHLO atlrel8.hp.com")
	by vger.kernel.org with ESMTP id S1161887AbWKJTEf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Nov 2006 14:04:35 -0500
To: Al Viro <viro@ftp.linux.org.uk>
In-Reply-To: <20061110182031.GO29920@ftp.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Al Viro wrote:
> so -= 1 is broken even on ia64 and it's *always* broken on big-endian
> boxen.

It's not broken in ia64, I've tested that, just don't have an x86 for 
testing right now.  Can you please apply these changes and prove it's 
broken?  This little trick has been done in other UNIXes for years 
without any problems.

-Brian
