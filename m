From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ss: Use rtnl_dump_filter in
 handle_netlink_request
Date: Wed, 3 Dec 2014 09:51:23 -0800
Message-ID: <20141203095123.40429f4c@urahara>
References: <1417531984-3522-1-git-send-email-vadim4j@gmail.com>
	<20141203092129.49f16769@urahara>
	<20141203172010.GA8639@angus-think.wlc.globallogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vadim4j@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:47560 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750730AbaLCRvd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 12:51:33 -0500
Received: by mail-pd0-f180.google.com with SMTP id p10so15956367pdj.39
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2014 09:51:32 -0800 (PST)
In-Reply-To: <20141203172010.GA8639@angus-think.wlc.globallogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 3 Dec 2014 19:20:10 +0200
vadim4j@gmail.com wrote:

> On Wed, Dec 03, 2014 at 09:21:29AM -0800, Stephen Hemminger wrote:
> > On Tue,  2 Dec 2014 16:53:04 +0200
> > Vadim Kochan <vadim4j@gmail.com> wrote:
> > 
> > > Replaced handling netlink messages by rtnl_dump_filter
> > > from lib/libnetlink.c, also:
> > > 
> > >     - removed unused dump_fp arg;
> > >     - added MAGIC_SEQ #define for 123456 seq id
> > > 
> > > Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> > 
> > This doesn't work correctly.
> > 
> > Simple test
> >   $ misc/ss >/dev/null
> > RTNETLINK answers: No such file or directory
> > RTNETLINK answers: No such file or directory
> > RTNETLINK answers: No such file or directory
> 
> Just tried, I did not get such errors.

I have OpenVPN running.
