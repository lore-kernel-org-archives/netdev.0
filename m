From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH 1/1] af_packet: don't enable timestamps in mmap'ed sockets
Date: Thu, 9 Aug 2007 18:33:22 +0400
Message-ID: <20070809143322.GA5345@2ka.mipt.ru>
References: <1186669314.24669.56.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Unai Uribarri <unai.uribarri@optenet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:53538 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965587AbXHIOd3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2007 10:33:29 -0400
Content-Disposition: inline
In-Reply-To: <1186669314.24669.56.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 09, 2007 at 04:21:54PM +0200, Unai Uribarri (unai.uribarri@optenet.com) wrote:
> The attached patch removes the automatic timestamp activation, that
> only mmap'ed AF_PACKET sockets perform. I known it can break user
> applications, but I believe that it's the correct solution.

How tcpdump with mmap libpcap will work with it?

-- 
	Evgeniy Polyakov
