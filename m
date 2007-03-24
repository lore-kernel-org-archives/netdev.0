From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: RFC: Established connections hash function
Date: Sat, 24 Mar 2007 16:29:11 +0300
Message-ID: <20070324132911.GA5629@2ka.mipt.ru>
References: <20070324122658.7240.qmail@science.horizon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: johnpol.2ka.mipt.ru@horizon.com, netdev@vger.kernel.org
To: linux@horizon.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:45235 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751036AbXCXNa1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Mar 2007 09:30:27 -0400
Content-Disposition: inline
In-Reply-To: <20070324122658.7240.qmail@science.horizon.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Mar 24, 2007 at 08:26:58AM -0400, linux@horizon.com (linux@horizon.com) wrote:
> > Result with jenkins:
> > 1 23880
> > 2 12108
> > 3 4040
> > 4 1019
> > 5 200
> > 6 30
> > 7 8
> > 8 1
> > 
> > Xor:
> > 1 65536
> 
> Precisely.  This means that the Xor hash SUCKS, because its output is conspicuously
> non-random.

XOR hash was specially designed for network environment, so it has the
ever best result (in this scenario, but it can be too easily controlled by attacker). 
It is not general purpose hash.

-- 
	Evgeniy Polyakov
