From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [Bonding-devel] Re: [SET 2][PATCH 2/8][bonding] Propagating master's settings to slaves
Date: Mon, 11 Aug 2003 16:28:39 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200308112328.h7BNSdYi015167@death.ibm.com>
References: <shmulik.hen@intel.com>
Cc: Jeff Garzik <jgarzik@pobox.com>, hadi@cyberus.ca,
   Laurent DENIEL <laurent.deniel@thalesatm.com>,
   bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shmulik.hen@intel.com
In-Reply-To: Message from Shmulik Hen <shmulik.hen@intel.com>
   of "Tue, 12 Aug 2003 02:15:18 +0300." <200308120215.18234.shmulik.hen@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


>The drive was to try and make ifenslave slimmer regarding those three 
>operations only in the way that any setting of the slave will be done 
>by the kernel module instead of the configuration application. There 
>is no real "brain" there anyway.

	Agreed.  One reason for adding all of that propogation of
settings from master to slave is so that ifenslave doesn't have to do
it.  The less mystic stuff that needs to be synchronized between the
two, the better.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
