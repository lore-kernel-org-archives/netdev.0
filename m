From: Or Gerlitz <ogerlitz@Voltaire.com>
Subject: Re: more findings/questions on vlans/bonds
Date: Thu, 16 Apr 2009 17:17:42 +0300
Message-ID: <49E73E06.5030708@Voltaire.com>
References: <Pine.LNX.4.64.0904071202110.14639@zuben.voltaire.com> <5325.1239113639@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:29712 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753058AbZDPORq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Apr 2009 10:17:46 -0400
In-Reply-To: <5325.1239113639@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> I played a bit with bonding vlans (2.6.29 active-backup mode) and it
>> doesn't seem to work - specifically, I noted that bonding doesn't issue
>> fail-over after I changed the current slave link status to down ("ifconfig
>> eth0.4001 down"). I suspect that the carrier based link monitoring scheme
>> is broken wrt to vlan devices 
[...]
>> I also played with a post 2.6.29 cut of Linus tree, and I couldn't bond vlans.

Hi Jay, 

Did you had the chance to look into the bonding-vlan-devices related issues
I came across when doing these tests?

Or.
