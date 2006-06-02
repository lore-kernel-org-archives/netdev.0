From: "Brian F. G. Bidulock" <bidulock@openss7.org>
Subject: Re: Question about tcp hash function tcp_hashfn()
Date: Fri, 2 Jun 2006 09:10:15 -0600
Message-ID: <20060602091015.C18533@openss7.org>
References: <20060531090301.GA26782@2ka.mipt.ru> <20060531035124.B3065@openss7.org> <20060531105814.GB7806@2ka.mipt.ru> <20060531.114127.14356069.davem@davemloft.net> <20060601060424.GA28087@2ka.mipt.ru> <87y7wgaze1.fsf@mid.deneb.enyo.de> <20060602074845.GA17798@2ka.mipt.ru>
Reply-To: bidulock@openss7.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Weimer <fw@deneb.enyo.de>,
	David Miller <davem@davemloft.net>, draghuram@rocketmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.openss7.com ([142.179.199.224]:1732 "EHLO gw.openss7.com")
	by vger.kernel.org with ESMTP id S932158AbWFBPKR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2006 11:10:17 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Content-Disposition: inline
In-Reply-To: <20060602074845.GA17798@2ka.mipt.ru>; from johnpol@2ka.mipt.ru on Fri, Jun 02, 2006 at 11:48:46AM +0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy,

I agree, even with constant source IP, the hash still should have
performed better (but didn't).  Constant source IP and varying
port is a realistic data set for a port proxy.
