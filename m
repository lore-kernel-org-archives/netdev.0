From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: Re: [PATCH net-next 4/4] bonding: add active_slaves attribute
Date: Sun, 29 Dec 2013 09:58:01 -0800
Message-ID: <72496F9D-17A0-4DE8-8540-ADD1C6729F88@cumulusnetworks.com>
References: <20131228071603.6296.23176.stgit@monster-03.cumulusnetworks.com> <20131228214031.GE2447@minipsycho>
Mime-Version: 1.0 (Mac OS X Mail 7.0 \(1822\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Netdev <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:58407 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751705Ab3L2R6V convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Dec 2013 12:58:21 -0500
In-Reply-To: <20131228214031.GE2447@minipsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Dec 28, 2013, at 1:40 PM, Jiri Pirko <jiri@resnulli.us> wrote:

> Sat, Dec 28, 2013 at 08:16:03AM CET, sfeldma@cumulusnetworks.com wrot=
e:
>> Add active_slaves list to sysfs and netlink interfaces.
>=20
> I do not like this one bit. This information should be exported per-s=
lave.
> Not by master device.
>=20
> I think we should ass sysfs and netlink entries for slaves similar to
> how bridge does it for its ports.

Ok, i=92ll look at bridge for ideas.  Thanks for reviewing.

-scott