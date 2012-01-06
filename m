From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [net-next 8/9] ixgbe: add interface to export thermal data
Date: Thu, 5 Jan 2012 19:03:56 -0800
Message-ID: <20120105190356.41a8907c@nehalam.linuxnetplumber.net>
References: <1324631357-31789-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1324631357-31789-9-git-send-email-jeffrey.t.kirsher@intel.com>
	<CAHXqBFL_44T5nQVA=n03aT9Q1QpsLCY2dn9o6GE-9Rm66DSt-A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	Don Skidmore <donald.c.skidmore@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: =?ISO-8859-2?B?TWljaGGzIE1pcm9zs2F3?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56670 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758298Ab2AFDD7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 22:03:59 -0500
In-Reply-To: <CAHXqBFL_44T5nQVA=n03aT9Q1QpsLCY2dn9o6GE-9Rm66DSt-A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 23 Dec 2011 18:58:48 +0100
Micha=B3 Miros=B3aw <mirqus@gmail.com> wrote:

> 2011/12/23 Jeff Kirsher <jeffrey.t.kirsher@intel.com>:
> > From: Don Skidmore <donald.c.skidmore@intel.com>
> >
> > Some of our adapters have thermal data available, this patch export=
s this
> > data via a read-only sysfs interface.
>=20
> Just curious: can't this use the hwmon subsystem to be consistent wit=
h
> other system monitoring devices?
>=20
> Best Regards,
> Micha=B3 Miros=B3aw

There is also libsensors support in net-snmp, so if you use standard AP=
I's
the values can be monitored with standard management tools.
