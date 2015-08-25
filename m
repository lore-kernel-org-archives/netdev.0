From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH iproute2] add support for brief output for link and
 addresses
Date: Mon, 24 Aug 2015 18:03:31 -0700
Message-ID: <20150825010331.GL504@gospo.home.greyhouse.net>
References: <9a703fa7b69649518cbe0341ff261fe2@HQ1WP-EXMB11.corp.brocade.com>
 <20150824140829.7d014d87@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:34283 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751352AbbHYBDe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2015 21:03:34 -0400
Received: by pdbfa8 with SMTP id fa8so59745645pdb.1
        for <netdev@vger.kernel.org>; Mon, 24 Aug 2015 18:03:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150824140829.7d014d87@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 24, 2015 at 02:08:29PM -0700, Stephen Hemminger wrote:
> On Mon, 24 Aug 2015 20:41:16 +0000
> Andy Gospodarek <gospo@cumulusnetworks.com> wrote:
> 
> > This adds support for slightly less output than is normally provided by
> > 'ip link show' and 'ip addr show'.  This is a bit better when you have a
> > host with lots of interfaces.  Sample output:
> > 
> > $ ip -br link show
> > lo               UNKNOWN  00:00:00:00:00:00  <LOOPBACK,UP,LOWER_UP>
> > p7p1             UP       08:00:27:9d:62:9f  <BROADCAST,MULTICAST,UP,LOWER_UP>
> > p8p1             DOWN     08:00:27:dc:d8:ca  <NO-CARRIER,BROADCAST,MULTICAST,UP>
> > p9p1             UP       08:00:27:76:d9:75  <BROADCAST,MULTICAST,UP,LOWER_UP>
> > p7p1.100@p7p1    UP       08:00:27:9d:62:9f  <BROADCAST,MULTICAST,UP,LOWER_UP>
> > 
> > $ ip -br -4 addr show
> > lo               UNKNOWN  127.0.0.1/8
> > p7p1             UP       70.0.0.1/24
> > p8p1             DOWN     80.0.0.1/24
> > p7p1.100@p7p1    UP       200.0.0.1/24
> > 
> > $ ip -br -6 addr show
> > lo               UNKNOWN  ::1/128
> > p7p1             UP       7000::1/8 fe80::a00:27ff:fe9d:629f/64
> > p8p1             DOWN     8000::1/8
> > p9p1             UP       fe80::a00:27ff:fe76:d975/64
> > p7p1.100@p7p1    UP       fe80::a00:27ff:fe9d:629f/64
> > 
> > $ ip -br  addr show p7p1
> > p7p1             UP       70.0.0.1/24 7000::1/8 fe80::a00:27ff:fe9d:629f/64
> > 
> > Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
> 
> Cool, we could colorize this as well :-)

Will do, v2 coming up!
