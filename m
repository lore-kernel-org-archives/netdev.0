From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC PATCH v2 0/9] bql: Byte Queue Limits
Date: Fri, 12 Aug 2011 17:38:44 -0700
Message-ID: <20110812173844.08974336@nehalam.ftrdhcpuser.net>
References: <alpine.DEB.2.00.1108072129010.13386@pokey.mtv.corp.google.com>
	<20110812112025.5788de0b@nehalam.ftrdhcpuser.net>
	<CA+mtBx-nezRVZ7Q3h1uFCycEK6bL+ZsBR8Go69KsMu+g0UYvLw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33613 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753120Ab1HMAij convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2011 20:38:39 -0400
In-Reply-To: <CA+mtBx-nezRVZ7Q3h1uFCycEK6bL+ZsBR8Go69KsMu+g0UYvLw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 12 Aug 2011 17:33:24 -0700
Tom Herbert <therbert@google.com> wrote:

> > 1. Need a way to configure the values. =A0My preference would be ne=
w
> > =A0 netlink attribute and via 'ip link set' ...
> >
> As opposed to using sysfs entries?

Both are useful. But netlink is more consistent and has the
ability to be used as a transport.
