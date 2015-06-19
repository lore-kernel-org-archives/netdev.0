From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH next v3] bonding: Display LACP info only to CAP_NET_ADMIN
 capable user
Date: Fri, 19 Jun 2015 13:07:31 -0400
Message-ID: <20150619170730.GR588@gospo.home.greyhouse.net>
References: <1434652254-17510-1-git-send-email-maheshb@google.com>
 <20150619030010.GP588@gospo.home.greyhouse.net>
 <CAF2d9jjpzE+M0mKgTu_HL_b4zn4WimLK8We0bH-AyEuUiFD7yw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f175.google.com ([209.85.220.175]:35311 "EHLO
	mail-qk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752164AbbFSRHf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2015 13:07:35 -0400
Received: by qkbp125 with SMTP id p125so59754674qkb.2
        for <netdev@vger.kernel.org>; Fri, 19 Jun 2015 10:07:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAF2d9jjpzE+M0mKgTu_HL_b4zn4WimLK8We0bH-AyEuUiFD7yw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 19, 2015 at 10:02:39AM -0700, Mahesh Bandewar wrote:
> On Thu, Jun 18, 2015 at 8:00 PM, Andy Gospodarek
> <gospo@cumulusnetworks.com> wrote:
[...]
> > With this patch, actor_oper_port_state and partner_oper.port_state are
> > not displayed in /proc, but that information is available via netlink
> > from bond_fill_slave_info().
> >
> > I suspect you do not deem these two values as critical to the security
> > of the system, but wanted to confirm before ACKing.
> >
> Yes, one can very easily figure out that LACP is used in the system
> with parameters like bond-mode, lacp-rate, or the port-state. I feel
> these do not need to be hidden from unprivileged users to ensure
> security. Principally hiding enough to ensure security would be good
> rather than hiding everything. However if there is a scenario where
> exposing these values is a threat (in the same sense) then it's not
> lot of extra work to achieve that and I'm open to make those change.

Sounds fine to me.  I just wanted to be sure the diffrence between the
information displayed in various modes was intentional (or at least not
unintentional) and did not conflict with your plans.

Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
