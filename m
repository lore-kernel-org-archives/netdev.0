From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] enic: use kasprintf instead of snprintf
Date: Sun, 18 Jun 2017 22:59:12 -0700
Message-ID: <1497851952.8495.42.camel@perches.com>
References: <20170619050537.6393-1-gvaradar@cisco.com>
         <1497850852.8495.41.camel@perches.com>
         <alpine.LNX.2.20.1706182248450.15793@cae-iprp-alln-lb.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, benve@cisco.com
To: Govindarajulu Varadarajan <gvaradar@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0199.hostedemail.com ([216.40.44.199]:37933 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751053AbdFSF7P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2017 01:59:15 -0400
In-Reply-To: <alpine.LNX.2.20.1706182248450.15793@cae-iprp-alln-lb.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2017-06-18 at 22:55 -0700, Govindarajulu Varadarajan wrote:
> On Sun, 18 Jun 2017, Joe Perches wrote:
> 
> > Perhaps it'd be better to use a style
> > with a variable length format precision
> > 
> > ie:
> > 
> > 	"%.*s-tx-%u", IFNAMSIZ - 4 - <something>, netdev-name, i)
> > 
> 
> This would truncate interface name. Why is this preferred to my patch?

no allocation required, simpler.
