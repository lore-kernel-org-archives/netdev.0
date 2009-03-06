From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] macvlan: Support creating macvlans from macvlans
Date: Fri, 06 Mar 2009 09:07:49 -0800
Message-ID: <49B15865.10103@candelatech.com>
References: <m1ocwfsgw7.fsf@fess.ebiederm.org> <49B12B20.7000602@trash.net>	<m1sklqohw2.fsf@fess.ebiederm.org> <49B13259.9040701@trash.net>	<m14oy6n15y.fsf@fess.ebiederm.org> <49B13C7D.10308@trash.net> <m1bpsellmv.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:48841 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751039AbZCFRHy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2009 12:07:54 -0500
In-Reply-To: <m1bpsellmv.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman wrote:
> Thanks.
> Would you be opposed to changes that made macvlan more robust.
> Such as refusing to come up if the macaddress is already in use.
> And perhaps denying the sending of packets with the wrong source
> mac?
>   
I wouldn't deny sending with wrong source mac..ethernet interfaces can 
do this,
and mac-vlan should look as much like ethernet is possible.

I'm all for making it harder to mis-configure things (like dup macs on 
single interface,
etc).

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


