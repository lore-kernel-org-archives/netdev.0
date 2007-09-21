From: Michael Buesch <mb@bu3sch.de>
Subject: Re: net-2.6.24 - build failure
Date: Fri, 21 Sep 2007 18:18:04 +0200
Message-ID: <200709211818.05232.mb@bu3sch.de>
References: <1190238802.26101.24.camel@localhost> <20070919.151712.66176476.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:41021
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759476AbXIUQUh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2007 12:20:37 -0400
In-Reply-To: <20070919.151712.66176476.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 20 September 2007 00:17:12 David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Wed, 19 Sep 2007 14:53:22 -0700
> 
> > drivers/net/wireless/b43legacy/built-in.o: In function `tsf_read_file':
> > drivers/net/wireless/b43legacy/debugfs.c:80: multiple definition of `tsf_read_file'
> 
> Can one of the wireless folks fix b43legacy to not use the same
> global variable and function names as the b43 driver?

Fixes are already submitted.
This was only an accident (forgot static).

-- 
Greetings Michael.
