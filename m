From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RFC,PATCH] fastroute dead code...
Date: Fri, 30 Jul 2004 17:08:54 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <410AB8E6.1010102@pobox.com>
References: <20040730060348.GA22854@havoc.gtf.org> <ea86ce220407301229522be64f@mail.gmail.com> <20040730193515.GA11365@havoc.gtf.org> <ea86ce2204073013292c055a3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Tim Mattox <tmattox@gmail.com>
In-Reply-To: <ea86ce2204073013292c055a3@mail.gmail.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Tim Mattox wrote:
>>It is dead code, as-is, in the kernel.  It would require patches to
>>actually work at all.
>>
>>It is impossible that fastrouting is being actively used, without patches.
>>
>>        Jeff
> 
> 
> Some might consider dropping in a new network driver module a patch,
> others wouldn't...  Anyway, as I said before, IMHO I agree its dead code
> worthy of removal unless someone comes up with a GigE driver that
> actually uses it.


Driver use is completely irrelevant :)

Regardless of what any driver does, the IPv4 code in the kernel does not 
make use of the RTCF_FAST flag, once set.  All the fastrouting driver 
support API/code amounts to precisely nothing.

Unless the --core net stack-- is patched again to support fastrouting, 
all this is dead code.

	Jeff
