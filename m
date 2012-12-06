From: Erwin Rol <mailinglists@erwinrol.com>
Subject: Re: at91sam9260 MACB problem with IP fragmentation
Date: Thu, 06 Dec 2012 16:15:32 +0100
Message-ID: <50C0B694.60408@erwinrol.com>
References: <50C08233.9030905@erwinrol.com> <50C09D2E.8050608@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Havard Skinnemoen <havard@skinnemoen.net>,
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
	matteo.fortini@sadel.it, netdev <netdev@vger.kernel.org>
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50C09D2E.8050608@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey Nicolas,

On 6-12-2012 14:27, Nicolas Ferre wrote:
> Erwin,
> 
> On 12/06/2012 12:32 PM, Erwin Rol :
>> Hello Nicolas, Havard, all,
>>
>> I have a very obscure problem with a at91sam9260 board (almost 1 to 1
>> copy of the Atmel EK).
>>
>>  <snip>
>>
> [..]
> 
> It seems that Matteo has the same behavior: check here:
> http://www.spinics.net/lists/netdev/msg218951.html

The difference seems to be that in Matteo's case the receiving stalls.
In my case it is the sending that stalls. I see the UDP datagram in
userspace and the sendto call also returns without error, but the data
does not end up on the network (until the next packet is send)

> I am working on the macb driver right now, so I will try to reproduce
> and track this issue on my side.

That would be really great, and thank you for the quick reply. If you
have anything that I should try or test on my hardware just let me know.

BTW: A quick check on a at91sam9263 board did not show the problem. I
will try to verify if it really does work on a 9263, cause maybe it just
more rare on a 9263.

- Erwin
