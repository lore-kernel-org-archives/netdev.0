From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: iproute2 tc: Print qdisc, stats, class, filter info to string
 rather than FILE
Date: Thu, 8 Jan 2015 01:46:08 +0200
Message-ID: <20150107234608.GA1073@angus-think.lan>
References: <20150107215331.GA19197@angus-think.lan>
 <20150107150828.5b61f26f@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:51181 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755708AbbAGX4c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 18:56:32 -0500
Received: by mail-la0-f49.google.com with SMTP id hs14so6531905lab.8
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 15:56:30 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20150107150828.5b61f26f@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 07, 2015 at 03:08:28PM -0800, Stephen Hemminger wrote:
> On Wed, 7 Jan 2015 23:53:31 +0200
> Vadim Kochan <vadim4j@gmail.com> wrote:
> 
> > Hi,
> > 
> > I'd like to make possible to generate plot info about class hierarchy
> > with qdisc, filters, stats info, but I see that all this staffs are
> > printed to 'FILE *fp' which makes this hard to implement and seems to me
> > that it should be changed to be printed to 'char *s' (memory safety
> > should be considered by asprintf or similar), so this is a big change
> > but all this is possible and I ready to do it, but before do it I'd like
> > to ask if this could be acceptable as idea.
> > 
> > BUT maybe someone can advise me easier solution ?
> > 
> > Regards,
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> Rather than screen scraping tc command, why not use libmnl and get the
> data you want programmatically.

I'd like to have text info from tc on screen and output on the other
data format to be the same, just only for this.
