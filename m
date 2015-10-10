From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next RFC 2/3] switchdev: allow caller to explicitly
 use deferred attr_set version
Date: Sat, 10 Oct 2015 09:30:05 +0200
Message-ID: <20151010073005.GD1990@nanopsycho.orion>
References: <1444242652-17260-1-git-send-email-jiri@resnulli.us>
 <1444242652-17260-3-git-send-email-jiri@resnulli.us>
 <CAE4R7bAUQ+bPe0fMZsULnTuZKg4t2-RterSqKDS2H=OzZpW1Nw@mail.gmail.com>
 <20151008053933.GA2186@nanopsycho.orion>
 <CAE4R7bCozKS8e4SLKHLZVkq8n-OYXyjEni=vyZHo540WbxvbiA@mail.gmail.com>
 <20151008082631.GB2186@nanopsycho.orion>
 <CAE4R7bAXqd6HeO-FxONXJgJTGVvgv5JawxGtZJvidZ4Uc4ePJw@mail.gmail.com>
 <20151009064638.GG2161@nanopsycho.orion>
 <CAE4R7bACFY0npZ2UBcWf8J1YimnpZRWah0=4oQ=+y0fh7zEJVw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>, eladr@mellanox.com,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	john fastabend <john.fastabend@gmail.com>,
	David Laight <David.Laight@aculab.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:35639 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751361AbbJJHaI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Oct 2015 03:30:08 -0400
Received: by wicge5 with SMTP id ge5so94495564wic.0
        for <netdev@vger.kernel.org>; Sat, 10 Oct 2015 00:30:07 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAE4R7bACFY0npZ2UBcWf8J1YimnpZRWah0=4oQ=+y0fh7zEJVw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Oct 10, 2015 at 04:43:43AM CEST, sfeldma@gmail.com wrote:

<snip>

>
>>
>>>
>>>patch 3/3 I haven't looked at yet...I'm stuck on 2/3.
>>
>> It is very similar to 2/3, only for obj_add/del.
>
>Do we have examples of a deferred obj add or del?  Maybe we should
>hold off adding that support until someone finds a use-case.  I'm kind
>of hoping there isn't a use-case, but who knows?

Just look at the patch :) fdb_del_external_learn()
