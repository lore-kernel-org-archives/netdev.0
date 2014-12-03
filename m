From: vadim4j@gmail.com
Subject: Re: [PATCH iproute2] ss: Use rtnl_dump_filter in
 handle_netlink_request
Date: Wed, 3 Dec 2014 19:45:06 +0200
Message-ID: <20141203174506.GA12511@angus-think.wlc.globallogic.com>
References: <1417531984-3522-1-git-send-email-vadim4j@gmail.com>
 <20141203092129.49f16769@urahara>
 <20141203172010.GA8639@angus-think.wlc.globallogic.com>
 <20141203095123.40429f4c@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:54189 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751444AbaLCRyt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 12:54:49 -0500
Received: by mail-wg0-f42.google.com with SMTP id z12so20553258wgg.1
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2014 09:54:48 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20141203095123.40429f4c@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 03, 2014 at 09:51:23AM -0800, Stephen Hemminger wrote:
> On Wed, 3 Dec 2014 19:20:10 +0200
> vadim4j@gmail.com wrote:
> 
> > On Wed, Dec 03, 2014 at 09:21:29AM -0800, Stephen Hemminger wrote:
> > > On Tue,  2 Dec 2014 16:53:04 +0200
> > > Vadim Kochan <vadim4j@gmail.com> wrote:
> > > 
> > > > Replaced handling netlink messages by rtnl_dump_filter
> > > > from lib/libnetlink.c, also:
> > > > 
> > > >     - removed unused dump_fp arg;
> > > >     - added MAGIC_SEQ #define for 123456 seq id
> > > > 
> > > > Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> > > 
> > > This doesn't work correctly.
> > > 
> > > Simple test
> > >   $ misc/ss >/dev/null
> > > RTNETLINK answers: No such file or directory
> > > RTNETLINK answers: No such file or directory
> > > RTNETLINK answers: No such file or directory
> > 
> > Just tried, I did not get such errors.
> 
> I have OpenVPN running.

Hm, it is reproduced only with this patch ?
If so I will try to setup OpenVPN ... can't imagine how it can be
related ...
