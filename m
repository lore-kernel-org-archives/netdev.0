From: Rayagond K <rayagond@vayavyalabs.com>
Subject: Re: XGMII patch
Date: Fri, 11 Oct 2013 19:04:00 +0530
Message-ID: <CAJ3bTp6Z-oThV3BPj3OUnEHc26fd5Zn1r3SFQZEeFCCODsHzDA@mail.gmail.com>
References: <CAJ3bTp5nqeHy1QA=aSiq-aCWzDo5=zvKeko431jAQcuOdZ2Svw@mail.gmail.com>
	<CAGVrzcZpZUVNg9zt3x0UsPuV1fSaEy89cg+1=t038_7FzPWjEw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, afleming@freescale.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:34683 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756027Ab3JKNeB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Oct 2013 09:34:01 -0400
Received: by mail-ob0-f175.google.com with SMTP id uz6so2741338obc.20
        for <netdev@vger.kernel.org>; Fri, 11 Oct 2013 06:34:00 -0700 (PDT)
In-Reply-To: <CAGVrzcZpZUVNg9zt3x0UsPuV1fSaEy89cg+1=t038_7FzPWjEw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 11, 2013 at 1:52 PM, Florian Fainelli <f.fainelli@gmail.com=
> wrote:
> Adding Andy in CC who is the original author
>
> Le 8 oct. 2013 07:19, "Rayagond K" <rayagond@vayavyalabs.com> a =E9cr=
it :
>
>
>>
>> Hi All,
>>
>> I came across some old patch series to support XGMII in PHYLIB -
>> http://lwn.net/Articles/463344/
>>
>> These patch are not available in mainline kernel still and also PHYL=
IB
>> doesn't support XGMII also.
>
> This patch set does much more than adding XGMII support, it also adds=
 a
> generic 10G driver, is that what you need or can you live with just
> extending phy_interface_t to know about XGMII and write your own PHY =
driver?

I need both ie generic 10G driver and extending phy_interface_t to
know about XGMII.

Currently PAL takes care of PHY driver and handles everything related
to PHY device, MAC driver has just registers to PAL and give some
callback function like read_phy, write_phy and adjust_link etc. But
PAL doesn't support XGMII yet, so this patch does that right ?

>
>>
>> Any plan for applying these patch to mainline kernel.
>
> There were some comments on the patchset and there does not seem to h=
ave
> been a follow up.

Since this patch adds generic 10G driver and extends PAL to support
XGMII, its worth to follow up comments and add this patch to mainline
kernel asap.
