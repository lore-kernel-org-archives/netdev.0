From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: IPV6 loopback bound socket succeeds connecting to remote host
Date: Thu, 02 Dec 2010 16:41:39 +0800
Message-ID: <4CF75BC3.1020606@cn.fujitsu.com>
References: <616589.97517.qm@web29017.mail.ird.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"yoshfuji@linux-ipv6.org >> YOSHIFUJI Hideaki"
	<yoshfuji@linux-ipv6.org>, David Miller <davem@davemloft.net>,
	pekkas@netcore.fi, jmorris@namei.org
To: Albert Pretorius <albertpretorius@yahoo.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:58425 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754912Ab0LBInW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Dec 2010 03:43:22 -0500
In-Reply-To: <616589.97517.qm@web29017.mail.ird.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Albert Pretorius wrote, at 12/02/2010 03:45 PM:
> Hi
> 
> --- On Wed, 1/12/10, Shan Wei <shanwei@cn.fujitsu.com> wrote:
>> I think it make nonsense to translate data between loopback
>> device and other e.g. eth0 device in same machine.
> 
> I agree, RFC4291 makes it clear for IPV6 that no interface should accept traffic from loopback, I should not have tried to make it behave like IPV4.
> I can not find an equivalent statement for IPV4 though, all I could find is this from RFC3330:
> 
>    127.0.0.0/8 - This block is assigned for use as the Internet host
>    loopback address.  A datagram sent by a higher level protocol to an
>    address anywhere within this block should loop back inside the host.
>    This is ordinarily implemented using only 127.0.0.1/32 for loopback,
>    but no addresses within this block should ever appear on any network
>    anywhere [RFC1700, page 5].
> 
> Do you perhaps know?

There are no same statement for IPv4 loopback address. I have checked RFC1122, RFC1700 and RFC5753 .		

-- 
Best Regards
-----
Shan Wei


> thank you,
> Albert Pretorius
> 
> 
>       
> 


