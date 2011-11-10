From: Dmitry Kravkov <dkravkov@gmail.com>
Subject: Re: [PATCH net-next 09/13] bnx2x: add pri_map module parameter
Date: Thu, 10 Nov 2011 22:21:45 +0200
Message-ID: <CAM8tLiN=E2=a0TEYgw6mc70-vJU0dHjP4F4PpKUk8+3zvQPnAg@mail.gmail.com>
References: <1320938054-31288-1-git-send-email-dmitry@broadcom.com>
	<1320938054-31288-10-git-send-email-dmitry@broadcom.com>
	<1320946787.2851.2.camel@bwh-desktop>
	<CAM8tLiMATfsH1mqmgrALX9o+5nWEahntCAc2ewm0RF_kbt=82A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dmitry Kravkov <dmitry@broadcom.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Ariel Elior <ariele@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:49485 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750965Ab1KJUVq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2011 15:21:46 -0500
Received: by bke11 with SMTP id 11so2680492bke.19
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2011 12:21:45 -0800 (PST)
In-Reply-To: <CAM8tLiMATfsH1mqmgrALX9o+5nWEahntCAc2ewm0RF_kbt=82A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Resending for netdev
On Thu, Nov 10, 2011 at 10:18 PM, Dmitry Kravkov <dkravkov@gmail.com> w=
rote:
>
> On Thu, Nov 10, 2011 at 7:39 PM, Ben Hutchings <bhutchings@solarflare=
=2Ecom> wrote:
>>
>> On Thu, 2011-11-10 at 17:14 +0200, Dmitry Kravkov wrote:
>> > From: Ariel Elior <ariele@broadcom.com>
>> >
>> > The optional parameter pri_map is used to map the
>> > skb->priority to a Class Of Service (CoS) in the HW.
>> > This 32 bit parameter is evaluated by the =A0driver as 8
>> > values of 4 bits each. Each nibble sets the desired
>> > HW queue number for that priority.
>> [...]
>>
>> You should implement ndo_tc_setup instead of adding a driver-specifi=
c
>> parameter (that should be per-device anyway).
>
> bnx2x has ndo_setup_tc, but the callback configures device for number=
 of traffic
> only, when=A0actual mapping of priority to cos is done according to D=
CB negotiation.
> The parameter allow user to force mapping if the link partner is not =
DCB capable.
>
