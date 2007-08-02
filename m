From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: strange tcp behavior
Date: Thu, 2 Aug 2007 16:04:53 +0400
Message-ID: <20070802120452.GB9975@2ka.mipt.ru>
References: <56697.212.93.96.73.1186035546.squirrel@mail.screen.lv> <20070802095550.GA27226@2ka.mipt.ru> <20070802101655.GA14749@2ka.mipt.ru> <36758.simon.1186054739@5ec7c279.invalid>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: john@screen.lv, netdev@vger.kernel.org
To: Simon Arlott <simon@fire.lp0.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:41530 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755549AbXHBMKd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Aug 2007 08:10:33 -0400
Content-Disposition: inline
In-Reply-To: <36758.simon.1186054739@5ec7c279.invalid>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 02, 2007 at 12:38:59PM +0100, Simon Arlott (simon@fire.lp0.eu) wrote:
> I just got multiple RSTs instead of a connection too. The second RST looks
> like it's from another connection - and a RST for a RST is wrong...

You should use iptables rule to block non-raw access:
iptables -I INPUT -p tcp --dport 50000 -j DROP

but even in that case I got valid session.

> -- 
> Simon Arlott

-- 
	Evgeniy Polyakov
