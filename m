From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [Bonding-devel] Re: [bonding] compatibilty issues
Date: Wed, 01 Oct 2003 12:25:19 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310011925.h91JPJXZ001948@death.ibm.com>
References: <chad@tindel.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Shmulik Hen <shmulik.hen@intel.com>, "David S. Miller" <davem@redhat.com>,
        "Chad N. Tindel" <chad@tindel.net>, jgarzik@pobox.com,
        bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
In-Reply-To: Message from "Chad N. Tindel" <chad@tindel.net>
   of "Wed, 01 Oct 2003 14:26:10 EDT." <20031001182610.GA25218@calma.pair.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


>> So here is what I did in the meantime:
>> * Created a version for 2.4 that puts back all old compatibility stuff 
>>   that was removed either during the propagation set or the cleanup 
>>   set.
>> * Created a version for 2.6 that puts back just the compatibility 
>>   stuff that was removed in the propagation set (BOND_SETHWADDR, since 
>>   we got a complaint from a RH9 user).
>> * Removed the mention of the multicast param from the read-me.
>> * Raised the ABI version to 2 so the new ifenslave keeps propagating 
>>   IP settings to slaves for older drivers, and doesn't do that for new 
>>   ones that contain Willy Tarreau's panic fix.
>
>I like this.

	Same here, but I'd like to have a list somewhere of what each
of the ABI versions is for and how they're supposed to behave.  It's
starting to look like we're going to be adding these on a semi-regular
basis, so we need to keep track of what each one does and why.

	I also don't have any major heartburn about leaving the OLD
thingies in 2.4.  I'd like to remove them, but part of my reason for
wanting to nuke them was to keep 2.4 and 2.6 identical, but we're not
doing that, so it's not as big a concern.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
