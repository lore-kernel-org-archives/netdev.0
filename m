From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2 0/3] ip netns: Run over all netns
Date: Fri, 9 Jan 2015 21:17:34 +0200
Message-ID: <20150109191734.GA25479@angus-think.lan>
References: <1420628662-9930-1-git-send-email-vadim4j@gmail.com>
 <CAHA+R7OpGoYx51DQfLhFiZmU_jMfd28G6kssgft6NQoFXj_X+A@mail.gmail.com>
 <20150108005212.GA10487@angus-think.lan>
 <CAHA+R7NPrBw_tN20adU6m0A0Toggo9SO9LpVV7WSaVa51Fyfsg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:49557 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751172AbbAIT2B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 14:28:01 -0500
Received: by mail-lb0-f174.google.com with SMTP id 10so10314763lbg.5
        for <netdev@vger.kernel.org>; Fri, 09 Jan 2015 11:27:59 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAHA+R7NPrBw_tN20adU6m0A0Toggo9SO9LpVV7WSaVa51Fyfsg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 09, 2015 at 10:49:50AM -0800, Cong Wang wrote:
> On Wed, Jan 7, 2015 at 4:52 PM, Vadim Kochan <vadim4j@gmail.com> wrote:
> > On Wed, Jan 07, 2015 at 04:04:14PM -0800, Cong Wang wrote:
> >> On Wed, Jan 7, 2015 at 3:04 AM, Vadim Kochan <vadim4j@gmail.com> wrote:
> >> > From: Vadim Kochan <vadim4j@gmail.com>
> >> >
> >> > Allow 'ip netns del' and 'ip netns exec' run over each network namespace names.
> >> >
> >> > 'ip netns exec' executes command forcely on eacn nsname.
> >> >
> >>
> >> Why this has to be done in iproute command?
> >> That is, why not just offloading this to a shell script like below?
> >>
> >> for ns in `ip netns show`;
> >> do
> >>      ip netns exec $ns ip link show.....
> >> done
> >
> > Hm, but would not it better to have it in iproute instead of collect
> > scripts ? Scripts allows to do a lot of things, but in this case it seems like a
> > feature which related to iproute.
> 
> iproute2 should keep a minimum set of features especially when
> a one-liner shell script can do that.

BTW, this script should have additional output of netns name
before the 'ip netns exec $ns ...' invocation.
