From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [patch net-next v4 3/7] switchdev: remove pointers from switchdev
 objects
Date: Mon, 12 Oct 2015 21:44:23 -0700
Message-ID: <561C8C27.20604@gmail.com>
References: <1444672467-20621-1-git-send-email-jiri@resnulli.us> <1444672986-20709-1-git-send-email-jiri@resnulli.us> <1444672986-20709-2-git-send-email-jiri@resnulli.us> <CAE4R7bBevBoQ=U7P98F2NEh97ocLgvZuc4cS0fZ9BYFapVeR3A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>,
	Elad Raz <eladr@mellanox.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	David Laight <David.Laight@aculab.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: Scott Feldman <sfeldma@gmail.com>, Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:35720 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751206AbbJMEok (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2015 00:44:40 -0400
Received: by pabve7 with SMTP id ve7so8929571pab.2
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 21:44:39 -0700 (PDT)
In-Reply-To: <CAE4R7bBevBoQ=U7P98F2NEh97ocLgvZuc4cS0fZ9BYFapVeR3A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15-10-12 08:01 PM, Scott Feldman wrote:
> On Mon, Oct 12, 2015 at 11:03 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>>
>> When object is used in deferred work, we cannot use pointers in
>> switchdev object structures because the memory they point at may be already
>> used by someone else. So rather do local copy of the value.
>>
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> 
> Acked-by: Scott Feldman <sfeldma@gmail.com>
> 

also fwiw

Reviewed-by: John Fastabend <john.r.fastabend@intel.com>
