From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next v2 2/2] net: dsa: mv88e6xxx: Clear the PDOWN bit on setup
Date: Tue, 29 Mar 2016 14:49:57 -0400
Message-ID: <87wpolgluy.fsf@ketchup.mtl.sfl>
References: <1459249908-4556-1-git-send-email-patrick@puiterwijk.org> <1459249908-4556-2-git-send-email-patrick@puiterwijk.org> <87fuv9fe39.fsf@ketchup.mtl.sfl> <20160329162825.GC4690@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Patrick Uiterwijk <patrick@puiterwijk.org>, linux@roeck-us.net,
	davem@davemloft.net, netdev@vger.kernel.org, dennis@ausil.us,
	pbrobinson@gmail.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:43878 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751877AbcC2SuH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2016 14:50:07 -0400
In-Reply-To: <20160329162825.GC4690@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew, Patrick,

Andrew Lunn <andrew@lunn.ch> writes:

> On Tue, Mar 29, 2016 at 12:23:06PM -0400, Vivien Didelot wrote:
>> Hi Patrick,
>> 
>> Two comments below.
>> 
>> Patrick Uiterwijk <patrick@puiterwijk.org> writes:
>> 
>> > +static int mv88e6xxx_power_on_serdes(struct dsa_switch *ds)
>> 
>> Since this function assumes the SMI lock is already held, its name
>> should be prefixed with _ by convention (_mv88e6xxx_power_on_serdes).
>
> We decided to drop at, since nearly everything would end up with a _
> prefix. The assert_smi_lock() should find any missing locks, and
> lockdep/deadlocks will make it clear when the lock is taken twice.

OK, I didn't know that. This makes sense. There is no need to respin a
v3 only for my previous &= comment then.

Thanks,
-v
