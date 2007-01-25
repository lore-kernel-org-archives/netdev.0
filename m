From: Larry Finger <larry.finger@lwfinger.net>
Subject: Re: [RFC PATCH] bcm43xx: set channel when the interface is brought
 up
Date: Thu, 25 Jan 2007 09:36:14 -0600
Message-ID: <45B8CE6E.1030508@lwfinger.net>
References: <1169707854.10593.41.camel@dv>	<a32f33a40701250347q5c9aa5fby785181f77fc9bb4@mail.gmail.com>	<20070125135033.7d7d7baf@griffin.suse.cz> <200701250905.33129.gene.heskett@verizon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, Jiri Benc <jbenc@suse.cz>,
	netdev@vger.kernel.org, Ivo Van Doorn <ivdoorn@gmail.com>
To: Gene Heskett <gene.heskett@verizon.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc13.worldnet.att.net ([204.127.131.117]:59363 "EHLO
	mtiwmhc13.worldnet.att.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1030199AbXAYPj1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jan 2007 10:39:27 -0500
In-Reply-To: <200701250905.33129.gene.heskett@verizon.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gene Heskett wrote:
> On Thursday 25 January 2007 07:50, Jiri Benc wrote:
>> On Thu, 25 Jan 2007 12:47:08 +0100, Ivo Van Doorn wrote:
>>> Correct, similar problems have been detected in rt2x00. The temporary
>>> solution in there is to demand a scanning operation after the
>>> interface has been brought up.
>> Scanning? No no no, please! That would be a clear bug and misbehaviour.
>>
>> Jiri
> 
> Oh?  I'm sitting here watching the tty0 screen of my lappy after x has 
> been started, and I have established a connection, but SoftMAC is still 
> logging its scan activity, starting with channel 1 and scanning 14 
> channels.  Its doing this at approximately 2 minute intervals.  So I 
> think we have your definition of a clear bug and misbehaviour.
> 

Are you running NetworkManager? If so, that is the source of the scanning.

Larry

