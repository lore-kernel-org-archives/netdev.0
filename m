From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: Patch to ip(8) manpage
Date: Sat, 03 Mar 2012 13:43:46 +0400
Message-ID: <4F51E7D2.7020909@msgid.tls.msk.ru>
References: <alpine.DEB.2.00.1203031007180.22132@bakacsin.ki.iif.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from isrv.corpit.ru ([86.62.121.231]:60104 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750885Ab2CCJnt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Mar 2012 04:43:49 -0500
In-Reply-To: <alpine.DEB.2.00.1203031007180.22132@bakacsin.ki.iif.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03.03.2012 13:18, Kiss Gabor (Bitman) wrote:
> Dear folks,
> 
> For a while I did not understand why I get
> "RTNETLINK answers: Numerical result out of range"
> message when adding more addresses to an interface.

Shouldn't the kernel return more appropriate (IMHO)
ENAMETOOLONG error code here?

/mjt
