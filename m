From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: iproute2 tc: Print qdisc, stats, class, filter info to string
 rather than FILE
Date: Wed, 7 Jan 2015 15:08:28 -0800
Message-ID: <20150107150828.5b61f26f@urahara>
References: <20150107215331.GA19197@angus-think.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:46635 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753673AbbAGXIh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 18:08:37 -0500
Received: by mail-pd0-f169.google.com with SMTP id z10so7465744pdj.0
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 15:08:37 -0800 (PST)
In-Reply-To: <20150107215331.GA19197@angus-think.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 7 Jan 2015 23:53:31 +0200
Vadim Kochan <vadim4j@gmail.com> wrote:

> Hi,
> 
> I'd like to make possible to generate plot info about class hierarchy
> with qdisc, filters, stats info, but I see that all this staffs are
> printed to 'FILE *fp' which makes this hard to implement and seems to me
> that it should be changed to be printed to 'char *s' (memory safety
> should be considered by asprintf or similar), so this is a big change
> but all this is possible and I ready to do it, but before do it I'd like
> to ask if this could be acceptable as idea.
> 
> BUT maybe someone can advise me easier solution ?
> 
> Regards,
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Rather than screen scraping tc command, why not use libmnl and get the
data you want programmatically.
