From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: changing MTU on b44 breaks eth0
Date: Wed, 05 Nov 2003 16:36:40 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FA96D68.4090806@pobox.com>
References: <1067888106.3366.20.camel@bluez.bueche.ch>	<20031103205335.GA7668@ee.oulu.fi>	<20031103151618.79704b30.davem@redhat.com>	<20031104111555.GA26860@ee.oulu.fi>	<20031104091355.70d6a3d1.davem@redhat.com>	<20031104211937.GA3888@ee.oulu.fi> <20031104132017.1d43a69c.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pekka Pietikainen <pp@ee.oulu.fi>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031104132017.1d43a69c.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Tue, 4 Nov 2003 23:19:37 +0200
> Pekka Pietikainen <pp@ee.oulu.fi> wrote:
> 
> 
>>On Tue, Nov 04, 2003 at 09:13:55AM -0800, David S. Miller wrote:
>>
>>>free_netdev() is being invoked before the device registration
>>>state advanced to NETREG_UNREGISTERED, likely unregister_netdev()
>>>has not been called first or a bogus pointer was passed into
>>>the routine.
>>
>>Ah, like a missing SET_NETDEV_DEV? :-)
> 
> 
> Wonderful, Jeff please integrate this b44 patch from Pekka.


If someone can send me the latest patch, certainly!  :)

There wasn't a patch appended to this message I'm replying to, nor did 
any of the patches I saw on netdev include a SET_NETDEV_DEV change...

	Jeff
