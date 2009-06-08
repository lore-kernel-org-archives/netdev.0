From: "Hennerich, Michael" <Michael.Hennerich@analog.com>
Subject: RE: [Uclinux-dist-devel] [PATCH 1/2] netdev: smsc911x: allowbuilding on Blackfin systems
Date: Mon, 8 Jun 2009 22:29:20 +0100
Message-ID: <8A42379416420646B9BFAC9682273B6D0B7F58CF@limkexm3.ad.analog.com>
References: <1244248640-22699-1-git-send-email-vapier@gentoo.org> <OF063E0F2B.DD999013-ON802575CF.006B45BD-802575CF.006BB3F8@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <Ian.Saturley@smsc.com>,
	<uclinux-dist-devel@blackfin.uclinux.org>
To: <Steve.Glendinning@smsc.com>, "Mike Frysinger" <vapier@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nwd2mail10.analog.com ([137.71.25.55]:15267 "EHLO
	nwd2mail10.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753069AbZFHV3Z convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 17:29:25 -0400
Content-Class: urn:content-classes:message
In-Reply-To: <OF063E0F2B.DD999013-ON802575CF.006B45BD-802575CF.006BB3F8@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

if EMBEDDED ?



>From: uclinux-dist-devel-bounces@blackfin.uclinux.org
[mailto:uclinux-dist-devel-
>bounces@blackfin.uclinux.org] On Behalf Of Steve.Glendinning@smsc.com
>> The smsc911x driver works fine on Blackfin systems, so add it to the
>arch
>> list in the Kconfig.
>>
>> Signed-off-by: Mike Frysinger <vapier@gentoo.org>
>
>Acked-by: Steve Glendinning <steve.glendinning@smsc.com>
>
>> side note ... does it even make sense to have this arch list in the
>first
>> place ?  the driver works with any platform who declares proper
platform
>> resources ...
>
>You're right, there's nothing "special" about ARM | SUPERH other than
they
>cover all the in-tree platforms using smsc911x.  The aim was to hide
this
>option from menuconfig on x86 etc, where this device is extremely
unlikely
>to be found.  Maybe there's a better way of doing this?
>
>Steve

if EMBEDDED ?

-Michael

