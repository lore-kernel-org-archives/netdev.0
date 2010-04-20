From: Scott Feldman <scofeldm@cisco.com>
Subject: Re: [net-next,1/2] add iovnl netlink support
Date: Tue, 20 Apr 2010 13:26:27 -0700
Message-ID: <C7F35C03.29CF4%scofeldm@cisco.com>
References: <201004201819.32970.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>, Chris Wright <chrisw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:43924 "EHLO
	sj-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755205Ab0DTU0o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 16:26:44 -0400
In-Reply-To: <201004201819.32970.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/20/10 9:19 AM, "Arnd Bergmann" <arnd@arndb.de> wrote:

>>> But that's only the case if the NIC itself is in VEPA mode. If that
>>> were the case, there would be no need for a kernel interface at all,
>>> because then we could just drive the port profile selection from user
>>> space.
>>> 
>>> The proposed interface only seems to make sense if you use it to
>>> configure the NIC itself! Why should it care about the port profile
>>> otherwise?
>> 
>> In the case of devices that can do adjacent switch negotiations directly.
> 
> I thought the idea to deal with those devices was to beat sense into
> the respective developers until they do the negotiation in software 8-)

When the device can do the negotiation directly with the switch, why does it
make sense to bypass that and use software on the host?  I don't think we'd
want to give up on link speed/duplex auto-negotiation and punt those setting
back to the user/host like in the old days.

-scott

