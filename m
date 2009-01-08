From: "Mike Frysinger" <vapier.adi@gmail.com>
Subject: Re: [PATCH 2/2] netdev: bfin_mac: enable VLAN support in Blackfin MAC driver
Date: Thu, 8 Jan 2009 14:05:33 -0500
Message-ID: <8bd0f97a0901081105q1e897254kad9a8533b5845403@mail.gmail.com>
References: <1231344879-26069-1-git-send-email-cooloney@kernel.org>
	 <1231344879-26069-3-git-send-email-cooloney@kernel.org>
	 <20090108.105531.176161465.davem@davemloft.net>
	 <8bd0f97a0901081101t6fdfa485rbd7ccc4e47691ddb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: cooloney@kernel.org, jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, graf.yang@analog.com
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.175]:17420 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755614AbZAHTFe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 14:05:34 -0500
In-Reply-To: <8bd0f97a0901081101t6fdfa485rbd7ccc4e47691ddb@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 8, 2009 at 14:01, Mike Frysinger wrote:
> On Thu, Jan 8, 2009 at 13:55, David Miller wrote:
>> We can get VLAN packets received and sent, using AF_PACKET
>> sockets, for example.  The chip should still respect those
>> even if VLAN proper is not being utilized.
>
> any tips on doing that ?

or rather, is there a driver or you two you can point out that is
doing this correctly ?  the ones i looked at seemed to be doing it
like the patch we posted ...
-mike
