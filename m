From: Florian Weimer <fw@deneb.enyo.de>
Subject: Re: Question about tcp hash function tcp_hashfn()
Date: Fri, 02 Jun 2006 19:26:53 +0200
Message-ID: <87ac8v8o4i.fsf@mid.deneb.enyo.de>
References: <20060531090301.GA26782@2ka.mipt.ru>
	<20060531035124.B3065@openss7.org> <20060531105814.GB7806@2ka.mipt.ru>
	<20060531.114127.14356069.davem@davemloft.net>
	<20060601060424.GA28087@2ka.mipt.ru>
	<87y7wgaze1.fsf@mid.deneb.enyo.de>
	<20060602074845.GA17798@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, draghuram@rocketmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Brian F. G. Bidulock" <bidulock@openss7.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.enyo.de ([212.9.189.167]:30402 "EHLO mail.enyo.de")
	by vger.kernel.org with ESMTP id S1750809AbWFBR1l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2006 13:27:41 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20060602074845.GA17798@2ka.mipt.ru> (Evgeniy Polyakov's message
	of "Fri, 2 Jun 2006 11:48:46 +0400")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Evgeniy Polyakov:

> :) thats true, but to be 100% honest I used different code to test for
> hash artifacts...

Ah, okay.

> But it still does not fix artifacts with for example const IP and random
> ports or const IP and linear port selection.

I see them now.  Hmm.  Is there a theoretical explanation for them?
