From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [patch net-next RFC 3/3] switchdev: introduce deferred variants
 of obj_add/del helpers
Date: Thu, 8 Oct 2015 16:21:44 +0300
Message-ID: <CAJ3xEMjq7bXCrWpHuZV5W8VZxYJX-60=UPW=QjbVUtjrJ9e-RQ@mail.gmail.com>
References: <1444242652-17260-1-git-send-email-jiri@resnulli.us>
	<1444242652-17260-4-git-send-email-jiri@resnulli.us>
	<CAJ3xEMhEupHZvdQfBucemQwyjtQUcwwc5D5MhYqpctJGqtcTsA@mail.gmail.com>
	<20151008082858.GC2186@nanopsycho.orion>
	<20151008130910.GJ2186@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, idosch@mellanox.com,
	Elad Raz <eladr@mellanox.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Andrew Lunn <andrew@lunn.ch>,
	john fastabend <john.fastabend@gmail.com>,
	David Laight <David.Laight@aculab.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f194.google.com ([209.85.213.194]:33052 "EHLO
	mail-ig0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755041AbbJHNVp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 09:21:45 -0400
Received: by igbbp9 with SMTP id bp9so2004653igb.0
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2015 06:21:44 -0700 (PDT)
In-Reply-To: <20151008130910.GJ2186@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 8, 2015 at 4:09 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> Thu, Oct 08, 2015 at 10:28:58AM CEST, jiri@resnulli.us wrote:
>>Thu, Oct 08, 2015 at 08:45:58AM CEST, gerlitz.or@gmail.com wrote:
>>>On Wed, Oct 7, 2015 at 9:30 PM, Jiri Pirko <jiri@resnulli.us> wrote:

>>>This introduced a regression to the 2-phase commit scheme, since the
>>>prepare commit can fail
>>>and that would go un-noticed toward the upper layer, agree?

>>Well, no. This still does the transaction for all lower devices in one
>>go. No change in that.

> Now I get it, yes you are right. But currently there is no code in
> kernel which would control retval of deferred attr_set or obj_add/del

I am not sure to understand your reply. You are saying that when the deferred
procedures complete (e.g fail in the prepare phase) they can't actually let
the upper layer to realize that this change isn't possible? this is
exactly the bug.


Or.


Or.
