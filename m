From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [RFC] bridge and friends: reduce TheLinuxWay(tm)
Date: Wed, 16 Oct 2013 14:50:50 -0400
Message-ID: <525EE00A.20209@redhat.com>
References: <525C62D5.3090004@mojatatu.com>	 <20131014144156.6dc52a78@nehalam.linuxnetplumber.net>	 <525E9AB1.6090502@mojatatu.com> <525EC8AF.6000902@redhat.com>	 <525ED1AE.7050101@mojatatu.com> <1381948550.2045.136.camel@edumazet-glaptop.roam.corp.google.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62594 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754635Ab3JPSu5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Oct 2013 14:50:57 -0400
In-Reply-To: <1381948550.2045.136.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/16/2013 02:35 PM, Eric Dumazet wrote:
> On Wed, 2013-10-16 at 13:49 -0400, Jamal Hadi Salim wrote:
>
>> I think we need some filtering in the kernel. As it stands today,
>> unfortunately you get everything ;-> I was suprised at the amount of
>> data i get from the kernel these days when i ask for a simple netdev
>> info (I think no less than 1K per netdev; everything from /proc entries
>> from some bread crumbs i dont see any use for.
>
> By the way, "ip link show dev xxxx" seems to dump all devices info from
> the kernel...
>
>

Right.  ip link show is dumb.  It asks for info from all devices and
then filters based on the device you asked for, but the filtering
is done in iproute instead of the kernel.

brdige command inherited this through code re-use.

-vlad
