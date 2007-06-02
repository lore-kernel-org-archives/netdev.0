From: jamal <hadi@cyberus.ca>
Subject: Re: [2/4] [IPV4]: Convert IPv4 devconf to an array
Date: Sat, 02 Jun 2007 07:47:50 -0400
Message-ID: <1180784870.4080.14.camel@localhost>
References: <20070602100132.GA9129@gondor.apana.org.au>
	 <20070602100252.GB9247@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.235]:30225 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752166AbXFBLry (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jun 2007 07:47:54 -0400
Received: by wx-out-0506.google.com with SMTP id t15so744443wxc
        for <netdev@vger.kernel.org>; Sat, 02 Jun 2007 04:47:52 -0700 (PDT)
In-Reply-To: <20070602100252.GB9247@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2007-02-06 at 20:02 +1000, Herbert Xu wrote:
> [IPV4]: Convert IPv4 devconf to an array
> 
> This patch converts the ipv4_devconf config members (everything except
> sysctl) to an array.  This allows easier manipulation which will be
> needed later on to provide better management of default config values.
> 

Nice.
What be even nicer (wink, wink) is to be able to generate events when
these values change. Thomas and I once had long discussions on that
topic. It could be as primitive as a select()/poll() kicking in
when /proc/sys/net/ipv4/conf/default changes.
BTW, the fact select() doesnt kick at all (been a while since i last
tried) is something that seems to be a bug.

cheers,
jamal

