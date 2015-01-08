From: Thomas Graf <tgraf@suug.ch>
Subject: Re: iproute2 tc: Print qdisc, stats, class, filter info to string
 rather than FILE
Date: Thu, 8 Jan 2015 00:06:20 +0000
Message-ID: <20150108000620.GF21149@casper.infradead.org>
References: <20150107215331.GA19197@angus-think.lan>
 <20150107150828.5b61f26f@urahara>
 <20150107234608.GA1073@angus-think.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:38323 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752084AbbAHAGW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 19:06:22 -0500
Content-Disposition: inline
In-Reply-To: <20150107234608.GA1073@angus-think.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/08/15 at 01:46am, Vadim Kochan wrote:
> I'd like to have text info from tc on screen and output on the other
> data format to be the same, just only for this.

Look at:
https://github.com/tgraf/libnl/blob/master/src/nl-tctree-list.c

It shows how to use an API to retrieve the information you want and
allows to pretty print tc entries.
