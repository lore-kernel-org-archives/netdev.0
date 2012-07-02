From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: AF_BUS socket address family
Date: Sun, 01 Jul 2012 22:49:06 -0600
Message-ID: <4FF12842.8080802@genband.com>
References: <1340988354-26981-1-git-send-email-vincent.sanders@collabora.co.uk>	<20120629.153656.1141845894730637434.davem@davemloft.net>	<20120629231236.GA28593@mail.collabora.co.uk> <20120629.161821.948325645333976311.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: vincent.sanders@collabora.co.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120629.161821.948325645333976311.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/29/2012 05:18 PM, David Miller wrote:
> From: Vincent Sanders<vincent.sanders@collabora.co.uk>
> Date: Sat, 30 Jun 2012 00:12:37 +0100
>
>> I had hoped you would have at least read the opening list where I
>> outlined the underlying features which explain why none of the
>> existing IPC match the requirements.
> I had hoped that you had read the part we told you last time where
> we explained why multicast and "reliable delivery" are fundamentally
> incompatible attributes.
>
> We are not creating a full address family in the kernel which exists
> for one, and only one, specific and difficult user.

For what it's worth, the company I work for (and a number of other 
companies) currently use an out-of-tree datagram multicast messaging 
protocol family based on AF_UNIX.

If AF_BUS were to be accepted, it would be essentially trivial for us to 
port our existing userspace messaging library to use it instead of our 
current protocol family, and we would almost certainly do so.

I'd love to see AF_BUS go in.

Chris Friesen
