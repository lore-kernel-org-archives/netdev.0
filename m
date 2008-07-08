From: Roland Dreier <rdreier@cisco.com>
Subject: Re: setsockopt()
Date: Tue, 08 Jul 2008 00:03:26 -0700
Message-ID: <adamyksx3gh.fsf@cisco.com>
References: <48725DFE.6000504@citi.umich.edu>
	<20080707142408.43aa2a2e@extreme> <48728B09.1050801@citi.umich.edu>
	<20080707.144912.76654646.davem@davemloft.net>
	<20080708045443.GA7726@2ka.mipt.ru>
	<20080708020235.388a7bd5.billfink@mindspring.com>
	<adar6a4x510.fsf@cisco.com> <20080708064324.GA11776@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bill Fink <billfink@mindspring.com>,
	David Miller <davem@davemloft.net>, aglo@citi.umich.edu,
	shemminger@vyatta.com, netdev@vger.kernel.org, rees@umich.edu,
	bfields@fieldses.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:26304 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751707AbYGHHD2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 03:03:28 -0400
In-Reply-To: <20080708064324.GA11776@2ka.mipt.ru> (Evgeniy Polyakov's message
	of "Tue, 8 Jul 2008 10:43:24 +0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > Maybe nuttcp by default sets very small socket buffer size?

strace shows no setsockopt() calls other than SO_REUSEADDR in the
default case.

 - R.
