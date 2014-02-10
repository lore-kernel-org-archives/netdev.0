From: Belisko Marek <marek.belisko@gmail.com>
Subject: Re: [PATCH] net: rfkill-regulator: Add devicetree support.
Date: Mon, 10 Feb 2014 21:05:31 +0100
Message-ID: <CAAfyv354SPRvqmN-AO0GmwNVcDG-6Pxenn8_gt+ta8HY8kJ9vQ@mail.gmail.com>
References: <1391802529-29861-1-git-send-email-marek@goldelico.com>
	<1392020862.4128.1.camel@jlt4.sipsolutions.net>
	<BF9457FD-CEED-4290-9150-57F51F6E42FC@goldelico.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	"ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Rob Landley <rob@landley.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	David Miller <davem@davemloft.net>,
	Grant Likely <grant.likely@linaro.org>,
	NeilBrown Brown <neilb@suse.de>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-wireless@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: "Dr. H. Nikolaus Schaller" <hns@goldelico.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:39292 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753768AbaBJUFf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 15:05:35 -0500
In-Reply-To: <BF9457FD-CEED-4290-9150-57F51F6E42FC@goldelico.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 10, 2014 at 9:54 AM, Dr. H. Nikolaus Schaller
<hns@goldelico.com> wrote:
> Am 10.02.2014 um 09:27 schrieb Johannes Berg:
>
>> On Fri, 2014-02-07 at 20:48 +0100, Marek Belisko wrote:
>>
>>> +#define RFKILL_TYPE_ALL             (0)
>>> +#define RFKILL_TYPE_WLAN    (1)
>>> +#define RFKILL_TYPE_BLUETOOTH       (2)
>>> +#define RFKILL_TYPE_UWB             (3)
>>> +#define RFKILL_TYPE_WIMAX   (4)
>>> +#define RFKILL_TYPE_WWAN    (5)
>>> +#define RFKILL_TYPE_GPS             (6)
>>> +#define RFKILL_TYPE_FM              (7)
>>> +#define RFKILL_TYPE_NFC             (8)
>>
>> This seems like a bad idea since there's an enum elsewhere in userspace
>> API already.
I know this is duplicate but in device tree we cannot use enums
(AFAIU include/dt-bindings are defines used in device tree files)
>
> Yes,
> you are right. It is defined in include/uapi/linux/rfkill.h
>
> Tnx,
> Nikolaus
>

BR,

marek

-- 
as simple and primitive as possible
-------------------------------------------------
Marek Belisko - OPEN-NANDRA
Freelance Developer

Ruska Nova Ves 219 | Presov, 08005 Slovak Republic
Tel: +421 915 052 184
skype: marekwhite
twitter: #opennandra
web: http://open-nandra.com
