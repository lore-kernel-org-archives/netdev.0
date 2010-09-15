From: =?UTF-8?B?S3J6eXN6dG9mIE9sxJlkemtp?= <ole@ans.pl>
Subject: Re: [33-stable regression ssb/broadcom]
Date: Wed, 15 Sep 2010 12:02:23 +0200
Message-ID: <4C9099AF.6030303@ans.pl>
References: <4C8E6192.2010003@mandriva.org> <20100913.122329.39186333.davem@davemloft.net> <20100913193647.GD4052@tuxdriver.com> <4C8E8AC2.2030201@mandriva.org> <4C8E8C73.60306@mandriva.org> <20100913210145.GA18969@suse.de> <4C9097BA.1080208@mandriva.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg KH <gregkh@suse.de>, "stable@kernel.org" <stable@kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	David Miller <davem@davemloft.net>,
	"Larry.Finger@lwfinger.net" <Larry.Finger@lwfinger.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Thomas Backlund <tmb@mandriva.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([195.187.34.71]:55845 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751615Ab0IOKK3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Sep 2010 06:10:29 -0400
In-Reply-To: <4C9097BA.1080208@mandriva.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2010-09-15 11:54, Thomas Backlund wrote:
> Greg KH skrev 14.9.2010 00:01:
>> On Mon, Sep 13, 2010 at 11:41:23PM +0300, Thomas Backlund wrote:
>>> Thomas Backlund skrev 13.9.2010 23:34:
>>>> John W. Linville skrev 13.9.2010 22:36:
>>>>> On Mon, Sep 13, 2010 at 12:23:29PM -0700, David Miller wrote:
>>>>>> From: Thomas Backlund<tmb@mandriva.org>
>>>>>> Date: Mon, 13 Sep 2010 20:38:26 +0300
>>>>>>
>>>>>>> In Mandriva 2010.1 we noticed that 2.6.33.7 broke ssb/Broadcom =
lan for
>>>>>>> several users...
>>>>>>>
>>>>>>> Issue is tracked at:
>>>>>>> https://qa.mandriva.com/show_bug.cgi?id=3D60968
>>>>>>>
>>>>>>> Reverting the commit restores a working lan.
>>>>>>>
>>>>>>> The offending commit is:
>>>>>>
>>>>>> Please always CC: netdev on networking reports, otherwise you ar=
e
>>>>>> very unlikely to get any experts looking into your issue.
>>>>>
>>>>> IIRC, there was a bad patch that got sent for the 2.6.33.y series=
=2E
>>>>> I thought it had been reverted or fixed already?
>>>>>
>>>>
>>>> Nope.
>>>>
>>>> It got added in 2.6.33.7
>>>> http://git.kernel.org/?p=3Dlinux/kernel/git/stable/linux-2.6.33.y.=
git;a=3Dcommit;h=3D6fb037c2ed8378c7ab0c1e00536ba6b2a866503e
>>>>
>>>
>>> After checking some more...
>>>
>>> I see the revert of the broken patch was done in 2.6.34.3 and a set
>>> of ssb patches replacing it...
>>>
>>> but it didn't happend for 2.6.33.y
>>
>> Yeah, I think I "dropped" support for .33 by then and I really didn'=
t
>> care anymore.
>>
>=20
> Yep.
> final 2.6.33.7 was released 8 days before 2.6.34.3.
>=20
>> Note, I have gotten a few rumblings that I should bring .33 back to =
life
>> for some loving due to a few distros relying on it, but I need to fi=
nd
>> the time in my schedule to do so...
>>
>=20
> Well,
> if you dont want to really bring it back to life, I'd suggest to simp=
ly
> released a 2.6.33.8 with only reverting the broken patch as it would
> "unbreak" the tree and call it a day :-)
>=20
> Otherwise...
> I now have merged the ssb fixes from 26.34.3:
> 19bfed793ee38ce027326a3c518ff6201f673a8d ssb: do not read SPROM if it
> does not exist
> 3ca696ca403b2715018bd5c693ab105c3a3ea888 ssb: Look for SPROM at
> different offset on higher rev CC
> a8515c84db1a9c9be19d8d873b059473474b6dab ssb: fix NULL ptr deref when
> pcihost_wrapper is used
> 8235ddc2cd7a3367b688e0ed52ab377eac6cfad4 ssb: Handle alternate SSPROM
> location
>=20
> into 2.6.33.7 after reverting the broken commit and have confirmation
> from users that it still works, so thats what I'll do for Mandriva 20=
10.1

If a new 2.6.33-stable kernel is going to be release there is one more
important bugfix worth to be backported:
 http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3D=
commitdiff_plain;h=3D719f835853a92f6090258114a72ffe41f09155cd

This bug is present in 2.6.33, 2.6.34 and 2.6.35.

Best regards,

			Krzysztof Ol=C4=99dzki
