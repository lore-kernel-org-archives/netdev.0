From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH] ixgb: Convert to new vlan model.
Date: Tue, 14 Dec 2010 13:53:19 -0800
Message-ID: <AANLkTikqSk5KJGE3x=fqCtCgvS1va5+fjko0W2iQ7H2Y@mail.gmail.com>
References: <1292298163-30343-1-git-send-email-jesse@nicira.com>
	<1292344315.20458.6.camel@bwh-desktop>
	<EA929A9653AAE14F841771FB1DE5A136602D675056@rrsmsx501.amr.corp.intel.com>
	<1292350359.20458.8.camel@bwh-desktop>
	<EA929A9653AAE14F841771FB1DE5A136602D6751C1@rrsmsx501.amr.corp.intel.com>
	<1292354121.20458.11.camel@bwh-desktop>
	<AANLkTimnSedKQhhL8xXQVKnEm3FpbfRQ_Nd9hPmGbHLJ@mail.gmail.com>
	<1292363231.20458.25.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:47862 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750906Ab0LNVxV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Dec 2010 16:53:21 -0500
Received: by fxm18 with SMTP id 18so1295950fxm.2
        for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 13:53:20 -0800 (PST)
In-Reply-To: <1292363231.20458.25.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 14, 2010 at 1:47 PM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> On Tue, 2010-12-14 at 13:29 -0800, Jesse Gross wrote:
>> On Tue, Dec 14, 2010 at 11:15 AM, Ben Hutchings
>> <bhutchings@solarflare.com> wrote:
>> > On Tue, 2010-12-14 at 12:08 -0700, Tantilov, Emil S wrote:
>> >> Ben Hutchings wrote:
>> >> > On Tue, 2010-12-14 at 11:09 -0700, Tantilov, Emil S wrote:
>> >> >> Ben Hutchings wrote:
>> >> >>> On Mon, 2010-12-13 at 19:42 -0800, Jesse Gross wrote:
> [...]
>> >> >>> I think this should reject attempts to change just one flag w=
ith
>> >> >>> -EINVAL, rather than quietly 'fixing' the setting.
> [...]
>> Ben, I agree that limiting the settings to what is actually supporte=
d
>> is conceptually cleaner but in practice it's not very intuitive. =A0=
If
>> you try to turn something off and the response is that it's invalid,
>> most people are going to assume that you just can't do it. =A0This i=
s
>> especially true since you actually can't turn these settings off in
>> most drivers.
>>
>> There's a precedent for this type of thing: turn off TX checksum
>> offloading and watch scatter/gather and TSO be automatically disable=
d
>> as well. =A0It makes sense - the user requested a change, we do what=
 is
>> necessary to make that happen without requiring them to understand w=
hy
>> these features are interrelated.
>
> That reflects a general dependency and not a driver- or hardware-
> specific restriction. =A0But I see your point.
>
> Perhaps the ethtool utility should check the result after applying
> offload changes and report any additional automatic changes.

That sounds like the best solution to me.
