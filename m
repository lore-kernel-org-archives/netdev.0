From: Patrick Uiterwijk <patrick@puiterwijk.org>
Subject: Re: [PATCH net-next v2 2/2] net: dsa: mv88e6xxx: Clear the PDOWN bit
 on setup
Date: Wed, 30 Mar 2016 00:58:04 +0000
Message-ID: <CAJweMdYPfk7v0VVZoKW3+ZFsKD=6ja-yCo0jjwygTwYE3D30fQ@mail.gmail.com>
References: <1459249908-4556-1-git-send-email-patrick@puiterwijk.org>
	<1459249908-4556-2-git-send-email-patrick@puiterwijk.org>
	<87fuv9fe39.fsf@ketchup.mtl.sfl>
	<20160329162825.GC4690@lunn.ch>
	<87wpolgluy.fsf@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrew Lunn <andrew@lunn.ch>, Guenter Roeck <linux@roeck-us.net>,
	davem@davemloft.net, netdev@vger.kernel.org,
	Dennis Gilmore <dennis@ausil.us>,
	Peter Robinson <pbrobinson@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f47.google.com ([209.85.213.47]:35086 "EHLO
	mail-vk0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753333AbcC3A6G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2016 20:58:06 -0400
Received: by mail-vk0-f47.google.com with SMTP id e6so41642927vkh.2
        for <netdev@vger.kernel.org>; Tue, 29 Mar 2016 17:58:05 -0700 (PDT)
In-Reply-To: <87wpolgluy.fsf@ketchup.mtl.sfl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vivien,

On Tue, Mar 29, 2016 at 6:49 PM, Vivien Didelot
<vivien.didelot@savoirfairelinux.com> wrote:
> Hi Andrew, Patrick,
>
> Andrew Lunn <andrew@lunn.ch> writes:
>
>> On Tue, Mar 29, 2016 at 12:23:06PM -0400, Vivien Didelot wrote:
>>> Hi Patrick,
>>>
>>> Two comments below.
>>>
>>> Patrick Uiterwijk <patrick@puiterwijk.org> writes:
>>>
>>> > +static int mv88e6xxx_power_on_serdes(struct dsa_switch *ds)
>>>
>>> Since this function assumes the SMI lock is already held, its name
>>> should be prefixed with _ by convention (_mv88e6xxx_power_on_serdes).
>>
>> We decided to drop at, since nearly everything would end up with a _
>> prefix. The assert_smi_lock() should find any missing locks, and
>> lockdep/deadlocks will make it clear when the lock is taken twice.
>
> OK, I didn't know that. This makes sense. There is no need to respin a
> v3 only for my previous &= comment then.

Does that mean the merger will fix this up?
Or that I'll roll a v3 when I get a reviewed-by for the second patch?

Thanks,
Patrick
