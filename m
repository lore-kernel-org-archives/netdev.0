From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ss: Use rtnl_dump_filter in
 handle_netlink_request
Date: Wed, 3 Dec 2014 15:07:48 -0800
Message-ID: <20141203150748.001d481e@urahara>
References: <1417531984-3522-1-git-send-email-vadim4j@gmail.com>
	<20141203092129.49f16769@urahara>
	<20141203172010.GA8639@angus-think.wlc.globallogic.com>
	<20141203095123.40429f4c@urahara>
	<20141203174506.GA12511@angus-think.wlc.globallogic.com>
	<CAMw6YJ+W0KCvGrfij990+BU2EsW6E4SEWJRsrRgk=vnq-okjzQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:65505 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752273AbaLCXH6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 18:07:58 -0500
Received: by mail-pa0-f49.google.com with SMTP id eu11so16672750pac.36
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2014 15:07:57 -0800 (PST)
In-Reply-To: <CAMw6YJ+W0KCvGrfij990+BU2EsW6E4SEWJRsrRgk=vnq-okjzQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 4 Dec 2014 00:15:54 +0200
Vadim Kochan <vadim4j@gmail.com> wrote:

> I established some simple OpenVPN connection (at least by the logs and
> ss I see that peer is connected), but
> I dont get any errors with ss.
> 
> So can you please provide some more info how did you tested this patch
> ? I am surprised that this is caused only
> by these changes ...
> 
> On Wed, Dec 3, 2014 at 7:45 PM,  <vadim4j@gmail.com> wrote:
> > On Wed, Dec 03, 2014 at 09:51:23AM -0800, Stephen Hemminger wrote:
> >> On Wed, 3 Dec 2014 19:20:10 +0200
> >> vadim4j@gmail.com wrote:
> >>
> >> > On Wed, Dec 03, 2014 at 09:21:29AM -0800, Stephen Hemminger wrote:
> >> > > On Tue,  2 Dec 2014 16:53:04 +0200
> >> > > Vadim Kochan <vadim4j@gmail.com> wrote:
> >> > >
> >> > > > Replaced handling netlink messages by rtnl_dump_filter
> >> > > > from lib/libnetlink.c, also:
> >> > > >
> >> > > >     - removed unused dump_fp arg;
> >> > > >     - added MAGIC_SEQ #define for 123456 seq id
> >> > > >
> >> > > > Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> >> > >
> >> > > This doesn't work correctly.
> >> > >
> >> > > Simple test
> >> > >   $ misc/ss >/dev/null
> >> > > RTNETLINK answers: No such file or directory
> >> > > RTNETLINK answers: No such file or directory
> >> > > RTNETLINK answers: No such file or directory
> >> >
> >> > Just tried, I did not get such errors.
> >>
> >> I have OpenVPN running.
> >
> > Hm, it is reproduced only with this patch ?
> > If so I will try to setup OpenVPN ... can't imagine how it can be
> > related ...

I am running on 3.17.4 kernel if that helps.
