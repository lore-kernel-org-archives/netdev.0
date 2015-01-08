From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: iproute2 tc: Print qdisc, stats, class, filter info to string
 rather than FILE
Date: Thu, 8 Jan 2015 03:02:30 +0200
Message-ID: <20150108010230.GA11821@angus-think.lan>
References: <20150107215331.GA19197@angus-think.lan>
 <20150107150828.5b61f26f@urahara>
 <20150107234608.GA1073@angus-think.lan>
 <20150108000620.GF21149@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:36718 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752409AbbAHBMy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 20:12:54 -0500
Received: by mail-la0-f45.google.com with SMTP id gq15so6763393lab.4
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 17:12:53 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20150108000620.GF21149@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 08, 2015 at 12:06:20AM +0000, Thomas Graf wrote:
> On 01/08/15 at 01:46am, Vadim Kochan wrote:
> > I'd like to have text info from tc on screen and output on the other
> > data format to be the same, just only for this.
> 
> Look at:
> https://github.com/tgraf/libnl/blob/master/src/nl-tctree-list.c
> 
> It shows how to use an API to retrieve the information you want and
> allows to pretty print tc entries.

OK, may be I am not clearly described what I am trying to do ...
So I think it might be useful to have an option in TC which would be
generate classes graph in plot format but keep the same text info as it
is printed on console by default. I just think to re-use the existing
code which prints that text info to console but use it for plot
generating. Do you think that this not right thing feature to be in TC
and it might better to have this separately from TC ?

Thanks,
