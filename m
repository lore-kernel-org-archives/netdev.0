From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH 1/2] net: dsa: mv88e6xxx: Introduce _mv88e6xxx_phy_page_{read,write}
Date: Sat, 26 Mar 2016 14:32:51 -0400
Message-ID: <87vb49gkdo.fsf@ketchup.mtl.sfl>
References: <1458951004-27424-1-git-send-email-patrick@puiterwijk.org> <56F5E9D1.9030909@roeck-us.net> <CAJweMdYoiA5mwHW3kSQOY0y46=GuLhnBor7mS3kXo9K3FGqW4g@mail.gmail.com> <56F5F71B.3090703@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, linux@arm.linux.org.uk, andrew@lunn.ch,
	netdev@vger.kernel.org, Dennis Gilmore <dennis@ausil.us>,
	Peter Robinson <pbrobinson@gmail.com>
To: Guenter Roeck <linux@roeck-us.net>,
	Patrick Uiterwijk <patrick@puiterwijk.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:45433 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751009AbcCZScz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Mar 2016 14:32:55 -0400
In-Reply-To: <56F5F71B.3090703@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Guenter,

Guenter Roeck <linux@roeck-us.net> writes:

>>> Is there some good reason for changing the name of those labels ?
>>
>> Vivien suggested to rename this since it makes more clear that this write is
>> meant to return to page 0 to make sure that phylib doesn't get confused
>> about the currently active page.
>>
>
> And "clear:" accomplishes that ? I would not have guessed.
> Wonder if anyone else does. I would have used a comment.
> 	/* Try to return to page 0 even after an error */
> or something like that.

"error" definitely doesn't make sense, especially in case of success. If
one has a better suggestion that "clear" for the label, I don't really
mind.

Thanks,
Vivien
