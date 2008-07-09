From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: setsockopt()
Date: Wed, 9 Jul 2008 09:25:35 +0400
Message-ID: <20080709052534.GA8157@2ka.mipt.ru>
References: <48725DFE.6000504@citi.umich.edu> <20080707142408.43aa2a2e@extreme> <48728B09.1050801@citi.umich.edu> <20080707.144912.76654646.davem@davemloft.net> <20080708045443.GA7726@2ka.mipt.ru> <20080708020235.388a7bd5.billfink@mindspring.com> <adar6a4x510.fsf@cisco.com> <20080708134845.2372a483@speedy> <20080708180500.e8a61231.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	Roland Dreier <rdreier@cisco.com>,
	David Miller <davem@davemloft.net>, aglo@citi.umich.edu,
	shemminger@vyatta.com, netdev@vger.kernel.org, rees@umich.edu,
	bfields@fieldses.org
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:37940 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751013AbYGIF0B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jul 2008 01:26:01 -0400
Content-Disposition: inline
In-Reply-To: <20080708180500.e8a61231.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 08, 2008 at 06:05:00PM -0400, Bill Fink (billfink@mindspring.com) wrote:
> BTW I believe there is one other important difference between the way
> the tcp_rmem/tcp_wmem autotuning parameters are handled versus the way
> the rmem_max/wmem_max parameters are used when explicitly setting the
> socket buffer sizes.  I believe the tcp_rmem/tcp_wmem autotuning maximum
> parameters are hard limits, with the default maximum tcp_rmem setting
> being ~170 KB and the default maximum tcp_wmem setting being 128 KB.

Maximum tcp_wmem depends on amount of available RAM, but at least 64k.
Maybe Reoland's distro set hard limit just to 128k...

-- 
	Evgeniy Polyakov
