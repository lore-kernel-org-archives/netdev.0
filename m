From: Belisko Marek <marek.belisko@gmail.com>
Subject: Re: [PATCH] net: rfkill-regulator: Add devicetree support.
Date: Sat, 8 Feb 2014 21:42:33 +0100
Message-ID: <CAAfyv34gykgnR6aTXwkH80A7CSphY-a99Ds7PgpNAO7t3cwxjg@mail.gmail.com>
References: <1391802529-29861-1-git-send-email-marek@goldelico.com>
	<20140208012225.d7a311c7.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Rob Herring <robh+dt@kernel.org>, Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	"ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Rob Landley <rob@landley.net>,
	linville <linville@tuxdriver.com>,
	johannes <johannes@sipsolutions.net>,
	davem <davem@davemloft.net>,
	Grant Likely <grant.likely@linaro.org>,
	NeilBrown <neilb@suse.de>,
	"Dr. H. Nikolaus Schaller" <hns@goldelico.com>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-wireless@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f49.google.com ([209.85.219.49]:55612 "EHLO
	mail-oa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751224AbaBHUme (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Feb 2014 15:42:34 -0500
In-Reply-To: <20140208012225.d7a311c7.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 8, 2014 at 7:22 AM, Bill Fink <billfink@mindspring.com> wrote:
> On Fri,  7 Feb 2014, Marek Belisko wrote:
>
>> Signed-off-by: NeilBrown <neilb@suse.de>
>> Signed-off-by: Marek Belisko <marek@goldelico.com>
>> ---
>> Based on Neil's patch and extend for documentation and bindings include.
>>
>>  .../bindings/net/rfkill/rfkill-relugator.txt       | 28 ++++++++++++++++
>
>                                   ^^^^^^^^^
>                                   Typo in file name.
Ah. Right. Thanks.
>
>                                         -Bill
>
>
>
>>  include/dt-bindings/net/rfkill-regulator.h         | 23 +++++++++++++
I also think this should be renamed to rfkill.h because same defines
could be used for rfkill-gpio driver.
>>  net/rfkill/rfkill-regulator.c                      | 38 ++++++++++++++++++++++
>>  3 files changed, 89 insertions(+)
>>  create mode 100644 Documentation/devicetree/bindings/net/rfkill/rfkill-relugator.txt
>>  create mode 100644 include/dt-bindings/net/rfkill-regulator.h
>>
>> diff --git a/Documentation/devicetree/bindings/net/rfkill/rfkill-relugator.txt b/Documentation/devicetree/bindings/net/rfkill/rfkill-relugator.txt
>> new file mode 100644
>> index 0000000..cdb7dd7
>> --- /dev/null
>> +++ b/Documentation/devicetree/bindings/net/rfkill/rfkill-relugator.txt
>> @@ -0,0 +1,28 @@
>> +Regulator consumer for rfkill devices
>> +
>> +Required properties:
>> +- compatible   : Must be "rfkill-regulator".
>> +- label  : Name of rfkill device.
>> +- type  : Type of rfkill device.
>> +
>> +Possible values (defined in include/dt-bindings/net/rfkill-regulator.h):
>> +     RFKILL_TYPE_ALL
>> +     RFKILL_TYPE_WLAN
>> +     RFKILL_TYPE_BLUETOOTH
>> +     RFKILL_TYPE_UWB
>> +     RFKILL_TYPE_WIMAX
>> +     RFKILL_TYPE_WWAN
>> +     RFKILL_TYPE_GPS
>> +     RFKILL_TYPE_FM
>> +     RFKILL_TYPE_NFC
>> +
>> +- vrfkill-supply - regulator device.
>> +
>> +Example:
>> +     gps-rfkill {
>> +             compatible = "rfkill-regulator";
>> +             label = "GPS";
>> +             type = <RFKILL_TYPE_GPS>;
>> +             vrfkill-supply = <&reg>;
>> +     };
>> +

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
