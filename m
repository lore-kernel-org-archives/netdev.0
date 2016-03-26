From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH 1/2] net: dsa: mv88e6xxx: Introduce
 _mv88e6xxx_phy_page_{read,write}
Date: Sat, 26 Mar 2016 13:57:00 -0700
Message-ID: <56F6F79C.2030102@roeck-us.net>
References: <1458951004-27424-1-git-send-email-patrick@puiterwijk.org>
 <56F5E9D1.9030909@roeck-us.net>
 <CAJweMdYoiA5mwHW3kSQOY0y46=GuLhnBor7mS3kXo9K3FGqW4g@mail.gmail.com>
 <56F5F71B.3090703@roeck-us.net> <87vb49gkdo.fsf@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux@arm.linux.org.uk, andrew@lunn.ch,
	netdev@vger.kernel.org, Dennis Gilmore <dennis@ausil.us>,
	Peter Robinson <pbrobinson@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Patrick Uiterwijk <patrick@puiterwijk.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:39611 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753882AbcCZU5E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Mar 2016 16:57:04 -0400
In-Reply-To: <87vb49gkdo.fsf@ketchup.mtl.sfl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/26/2016 11:32 AM, Vivien Didelot wrote:
> Hi Guenter,
>
> Guenter Roeck <linux@roeck-us.net> writes:
>
>>>> Is there some good reason for changing the name of those labels ?
>>>
>>> Vivien suggested to rename this since it makes more clear that this write is
>>> meant to return to page 0 to make sure that phylib doesn't get confused
>>> about the currently active page.
>>>
>>
>> And "clear:" accomplishes that ? I would not have guessed.
>> Wonder if anyone else does. I would have used a comment.
>> 	/* Try to return to page 0 even after an error */
>> or something like that.
>
> "error" definitely doesn't make sense, especially in case of success. If
> one has a better suggestion that "clear" for the label, I don't really
> mind.

Sounds like POV to me. I don't like changing label names, because someone
else may come the next day and change it again. At the end, one ends up
in a label name war. It also makes patches look more complicated than
necessary, and it _is_ an unrelated change. I don't understand the
problem with adding a comment, and using a label name in place of a
comment seems odd to me.

Anyway, this has all become philosophical, meaning I'll stay out of it.
Pick whatever you want ...

Cheers,
Guenter
