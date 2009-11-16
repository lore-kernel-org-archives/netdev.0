From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: Those gpio-mdio patches...
Date: Mon, 16 Nov 2009 13:21:45 -0500
Message-ID: <20091116182145.GB15157@caffeine.csclub.uwaterloo.ca>
References: <20091113.135908.249908732.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lsorense@csclub.uwaterloo.ca, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.csclub.uwaterloo.ca ([129.97.134.17]:54921 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751634AbZKPSVj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 13:21:39 -0500
Content-Disposition: inline
In-Reply-To: <20091113.135908.249908732.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 13, 2009 at 01:59:08PM -0800, David Miller wrote:
> Please don't fix the issue that way.  If the routine is returning a
> true or false value, make it return a 'bool' instead of an 'int'.
> That way we don't have to "accept something other than 0 and 1"

Hmm.  Well I just tried to fix what was already there.  gpio-lib does
NOT return 0 or 1, it returns 0 or 1 shifted by the gpio position in a
gpio register, but soemthing has to convert that to a boolean value.
Making it return a bool doesn't change the fact it needs the '!!' applied
to make it a bool.

I can look at changing the mdio-gpio to using bool instead of integer
where necesary.

-- 
Len Sorensen
