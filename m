From: "linux-os \(Dick Johnson\)" <linux-os@analogic.com>
Subject: RE: Router stops routing after changing MAC Address
Date: Mon, 13 Mar 2006 16:39:16 -0500
Message-ID: <Pine.LNX.4.61.0603131636470.5608@chaos.analogic.com>
References: <925A849792280C4E80C5461017A4B8A20321F5@mail733.InfraSupportEtc.com>
Reply-To: "linux-os \(Dick Johnson\)" <linux-os@analogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Stephen Hemminger" <shemminger@osdl.org>,
	"Chuck Ebbert" <76306.1226@compuserve.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	"Bart Samwel" <bart@samwel.tk>,
	"Alan Cox" <alan@lxorguk.ukuu.org.uk>,
	"Simon Mackinlay" <smackinlay@mail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932466AbWCMVj3@vger.kernel.org>
in-reply-to: <925A849792280C4E80C5461017A4B8A20321F5@mail733.InfraSupportEtc.com>
Content-class: urn:content-classes:message
To: "Greg Scott" <GregScott@InfraSupportEtc.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Mon, 13 Mar 2006, Greg Scott wrote:

> But in a failover scenario you want two devices to have the same IEEE
> (station) Address (or MAC Address or hardware address).  So many names
> for the same thing!
>
> When the primary unit fails, you want the backup unit to completely
> assume the failed unit's identity - right down to the MAC Address.  The
> other way to do it using gratuitous ARPs is not good enough because some
> cheap router someplace with an ARP cache of several hours will not
> listen and will never update its own ARP cache.
>
> I like to think of this as bending the rules a little bit, not really
> breaking them.  :)
>
> - Greg
>

Top posting, NotGood(tm). Anyway, if the device fails, you have
routers and hosts ARPing the interface, trying to establish a
route anyway.

>
>
>> Actually, it doesn't make any difference. Changing the IEEE station
>> (physical) address is not an allowed procedure even though hooks are
>> available in many drivers to do this. According to the IEEE 802
>> physical media specification, this 48-bit address must be unique
>> and must be one of a group assigned by IEEE. Failure to follow this
>> simple protocol can (will) cause an entire network to fail. If you
>> don't care, then you certainly don't care about multicast bits either,
>> basically let them set it to all ones as well.
>
>> Cheers,
>> Dick Johnson
>> Penguin : Linux version 2.6.15.4 on an i686 machine (5589.54 BogoMips).
>> Warning : 98.36% of all statistics are fiction, book release in April.
>

Cheers,
Dick Johnson
Penguin : Linux version 2.6.15.4 on an i686 machine (5589.54 BogoMips).
Warning : 98.36% of all statistics are fiction, book release in April.
_


****************************************************************
The information transmitted in this message is confidential and may be privileged.  Any review, retransmission, dissemination, or other use of this information by persons or entities other than the intended recipient is prohibited.  If you are not the intended recipient, please notify Analogic Corporation immediately - by replying to this message or by sending an email to DeliveryErrors@analogic.com - and destroy all copies of this information, including any attachments, without reading or disclosing them.

Thank you.
