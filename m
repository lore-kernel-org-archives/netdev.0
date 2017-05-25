From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ip6_tunnel, ip6_gre: fix setting of DSCP on
 encapsulated packets
Date: Thu, 25 May 2017 16:33:29 -0400 (EDT)
Message-ID: <20170525.163329.1506857538759050908.davem@davemloft.net>
References: <20170526054627.00dcdeeb@udesktop>
        <20170525.154914.1347048861561693629.davem@davemloft.net>
        <20170526060842.4bd21054@udesktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, stephen@networkplumber.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: petedaws@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170526060842.4bd21054@udesktop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter Dawson <petedaws@gmail.com>
Date: Fri, 26 May 2017 06:08:42 +1000

> On Thu, 25 May 2017 15:49:14 -0400 (EDT)
> David Miller <davem@davemloft.net> wrote:
> 
>> Still not correct, you need to use a "Fixes: " tag of the form:
>> 
>> Fixes: 90427ef5d2a4 ("ipv6: fix flow labels when the traffic class is non-0")
>> 
>> And it must appear of the first line of tags, before signoffs and acks,
>> with no empty lines in between.
> 
> Here is my proposed commit message in full. Note that 
> the "Fixes" line extends to 78 chars. Is this OK?

Yes, that looks perfect.
