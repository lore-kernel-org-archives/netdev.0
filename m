From: "Piotr Sawuk" <a9702387@unet.univie.ac.at>
Subject: Re: resurrecting tcphealth
Date: Mon, 16 Jul 2012 15:03:26 +0200
Message-ID: <cc2022d86834a8798518f9cccc605d45.squirrel@webmail.univie.ac.at>
References: <e9caf38359467bfa8a1e2ac86f6ef2cc.squirrel@webmail.univie.ac.at>
    <20120713165544.6767ea8f@nehalam.linuxnetplumber.net>
    <87741204cd72d363d54dadf9a94bb6fe.squirrel@webmail.univie.ac.at>
    <1342439185.23494.19.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain;charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from grace.univie.ac.at ([131.130.3.115]:46222 "EHLO
	grace.univie.ac.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751808Ab2GPND2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2012 09:03:28 -0400
In-Reply-To: <1342439185.23494.19.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mo, 16.07.2012, 13:46, Eric Dumazet wrote:
> On Mon, 2012-07-16 at 13:33 +0200, Piotr Sawuk wrote:
>> On Sa, 14.07.2012, 01:55, Stephen Hemminger wrote:
>> > I am not sure if the is really necessary since the most
>> > of the stats are available elsewhere.
>>
>> if by "most" you mean address and port then you're right.
>> but even the rtt reported by "ss -i" seems to differ from tcphealth.
>
> Thats because tcphealth is wrong, it assumes HZ=1000 ?
>
> tp->srtt unit is jiffies, not ms.

thanks. any conversion-functions in the kernel for that?
>
> tcphealth is a gross hack.

what would you do if you tried making it less gross?

I've not found any similar functionality, in the kernel.
I want to know an estimate for the percentage of data lost in tcp.
and I want to know that without actually sending much packets.
afterall I'm on the receiving end most of the time.
percentage of duplicate packets received is nice too.
you have any suggestions?
