From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH 1/1] af_packet: don't enable timestamps in mmap'ed sockets
Date: Fri, 10 Aug 2007 16:14:34 +0400
Message-ID: <20070810121434.GA6795@2ka.mipt.ru>
References: <1186669314.24669.56.camel@localhost.localdomain> <20070809143322.GA5345@2ka.mipt.ru> <1186683234.24669.65.camel@localhost.localdomain> <20070809181823.GA32449@2ka.mipt.ru> <1186685061.24669.76.camel@localhost.localdomain> <20070810083418.GA25479@2ka.mipt.ru> <1186746907.24669.107.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Unai Uribarri <unai.uribarri@optenet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:60494 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757221AbXHJMOk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2007 08:14:40 -0400
Content-Disposition: inline
In-Reply-To: <1186746907.24669.107.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 10, 2007 at 01:55:07PM +0200, Unai Uribarri (unai.uribarri@optenet.com) wrote:
> > This breaks compatibility. Add new socket option, which will really
> > disable it and do all your logic, but not breaking existing
> > applications.
> > 
> 
> Is SO_TIMESTAMP2 a valid name? I can't imagine how to call it.
 
:) what about name, which really shows what option does? 

-- 
	Evgeniy Polyakov
