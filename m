From: Jan Seiffert <kaffeemonster@googlemail.com>
Subject: Re: [REGRESSION][PATCH V4 1/3] bpf jit: Make the filter.c::__load_pointer
 helper non-static  for the jits
Date: Mon, 2 Apr 2012 15:02:53 +0200
Message-ID: <4F79A37D.5010605@googlemail.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B6ECE@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linuxppc-dev@lists.ozlabs.org>, Matt Evans <matt@ozlabs.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6ECE@saturn3.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Laight schrieb:
>  
>> The function is renamed to make it a little more clear what it does.
>> It is not added to any .h because it is not for general 
>> consumption, only for bpf internal use (and so by the jits).
> 
> I'd have thought it better to put in into a bfp_internal.h
> (or similar) with a big warning there about the asm users.
> 

Hmmm, OK, where would i put the .h? Right there under ./include/linux/?

> Possibly even worth adding some other defs that the asm
> files will need (if there are any).
> 

There is at least one other define, the lowest negative address range,
but it would be a copy of the same define in filter.h, or i would have
to massage filter.h to make it fit for inclusion by assembly.
So I'm unsure how to proceed.

> 	David
> 

Greetings
	Jan

-- 
An IPv4 address space walks into a bar: "A strong CIDR please. I'm
exhausted."
