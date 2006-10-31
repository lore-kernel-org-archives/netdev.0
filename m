From: Ben Greear <greearb@candelatech.com>
Subject: Re: Thousands of interfaces
Date: Tue, 31 Oct 2006 07:55:04 -0800
Message-ID: <454771D8.9080307@candelatech.com>
References: <20061031092550.GA8201@tufnell.london.poggs.net> <20061031.013154.122620846.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: peter.hicks@poggs.co.uk, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:4320 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S1422840AbWJaPxt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2006 10:53:49 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061031.013154.122620846.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Peter Hicks <peter.hicks@poggs.co.uk>
> Date: Tue, 31 Oct 2006 09:25:50 +0000
>
> [ Discussion belongs on netdev@vger.kernel.org, added to CC: ]
>
>   
>> I have a dual 3GHz Xeon machine with a 2.4.21 kernel and thousands (15k+) of
>> ipip tunnel interfaces.  These are being used to tunnel traffic from remote
>> routers, over a private network, and handed off to a third party.
>>     
>  ...
>   
>> Is it possible to speed up creation of the interfaces?  Currently it takes
>> around 24 hours.  Is there are more efficient way to handle a very large
>> number of IP-IP tunnels?  Would upgrading to a 2.6 kernel be of use?
>>     
>
>   
2.6 (and the associated 'ip' tool) does have some improvements for 
showing very
large numbers of interfaces.  I haven't tried more than a few thousand 
though...

Ben


-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


