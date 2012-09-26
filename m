From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 5/5] smsc95xx: enable power saving mode during system suspend
Date: Wed, 26 Sep 2012 17:48:24 +0200
Message-ID: <87txuk9453.fsf@nemi.mork.no>
References: <1348663224-30403-1-git-send-email-steve.glendinning@shawell.net>
	<1348663224-30403-6-git-send-email-steve.glendinning@shawell.net>
	<87y5jw982o.fsf@nemi.mork.no>
	<CAKh2mn5tKowqjbvgWDSz52UF9qY9_ysAb23Pb-M_3wvCG=_R6w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Steve Glendinning <steve@shawell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:45559 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752173Ab2IZPs1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2012 11:48:27 -0400
In-Reply-To: <CAKh2mn5tKowqjbvgWDSz52UF9qY9_ysAb23Pb-M_3wvCG=_R6w@mail.gmail.com>
	(Steve Glendinning's message of "Wed, 26 Sep 2012 16:16:27 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Steve Glendinning <steve@shawell.net> writes:
> On 26 September 2012 15:23, Bj=C3=B8rn Mork <bjorn@mork.no> wrote:
>> Steve Glendinning <steve.glendinning@shawell.net> writes:
>>
>>> +static int smsc95xx_suspend(struct usb_interface *intf, pm_message=
_t message)
>>> +{
>>> +     struct usbnet *dev =3D usb_get_intfdata(intf);
>>> +     int ret;
>>> +     u32 val;
>>> +
>>> +     BUG_ON(!dev);
>>
>> That's not very user friendly.  Why not just return here?
>
> I hadn't thought that was a situation that could arise, is it?  Would
> this happen if the USB device was removed during suspend?

No, it should not happen.  But then, why test at all?


Bj=C3=B8rn
