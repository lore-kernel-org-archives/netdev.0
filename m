From: Ben Greear <greearb@candelatech.com>
Subject: Re: [RFC] tulip VLAN support
Date: Wed, 05 Jan 2005 14:56:19 -0800
Message-ID: <41DC7093.2080705@candelatech.com>
References: <20050105193425.GY18847@sventech.com> <41DC6669.9090407@pobox.com> <20050105223147.GE18847@sventech.com> <41DC6E08.3080507@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Johannes Erdfelt <johannes@erdfelt.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <41DC6E08.3080507@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> What size do you need?  1504 bytes, right?

1500 MTU + 14 for header + 4 for CRC + 4 for VLAN == 1522

Normally, you just have to tell the chip to accept slightly larger frames
and/or ignore the over-size frame flag.  You do not actually need any ability
to set a larger than 1500 MTU.

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
