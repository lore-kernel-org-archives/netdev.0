From: Steve Glendinning <steve@shawell.net>
Subject: Re: [PATCH 5/5] smsc95xx: enable power saving mode during system suspend
Date: Wed, 26 Sep 2012 16:16:27 +0100
Message-ID: <CAKh2mn5tKowqjbvgWDSz52UF9qY9_ysAb23Pb-M_3wvCG=_R6w@mail.gmail.com>
References: <1348663224-30403-1-git-send-email-steve.glendinning@shawell.net>
	<1348663224-30403-6-git-send-email-steve.glendinning@shawell.net>
	<87y5jw982o.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:39807 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751455Ab2IZPQ2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2012 11:16:28 -0400
Received: by oagh16 with SMTP id h16so669126oag.19
        for <netdev@vger.kernel.org>; Wed, 26 Sep 2012 08:16:27 -0700 (PDT)
In-Reply-To: <87y5jw982o.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26 September 2012 15:23, Bj=F8rn Mork <bjorn@mork.no> wrote:
> Steve Glendinning <steve.glendinning@shawell.net> writes:
>
>> +static int smsc95xx_suspend(struct usb_interface *intf, pm_message_=
t message)
>> +{
>> +     struct usbnet *dev =3D usb_get_intfdata(intf);
>> +     int ret;
>> +     u32 val;
>> +
>> +     BUG_ON(!dev);
>
> That's not very user friendly.  Why not just return here?

I hadn't thought that was a situation that could arise, is it?  Would
this happen if the USB device was removed during suspend?

-Steve
