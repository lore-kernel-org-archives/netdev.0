From: Peter Bieringer <pb@bieringer.de>
Subject: Re: Re: Re: IPv6 enabled Network services
Date: Thu, 13 Feb 2003 13:13:54 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <31010000.1045138434@worker.muc.bieringer.de>
References: <20030213111557.21921.qmail@webmail27.rediffmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: santosh kumar gowda <ipv6_san@rediffmail.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20030213111557.21921.qmail@webmail27.rediffmail.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



--On Thursday, February 13, 2003 11:15:57 AM +0000 santosh kumar
gowda <ipv6_san@rediffmail.com> wrote:

> Dr.Peter,
> 
> I'm able to ping (using ping6) from both the machines.
> 
> But, when i perform telnet, in machine-1 with Linux version
> 2.4.18-3smp gcc version 2.96, Red Hat Linux 7.3, i get
> 
># telnet fe80::2b0:d0ff:fed2:65ff
> Trying fe80::2b0:d0ff:fed2:65ff
> telnet: connect to address fe80::2b0:d0ff:fed2:65ff: Invalid
> argument
> 
> And the machine-2 with Linux version 2.4.18-14 (gcc version 3.2
> 20020903 (Red Hat Linux 8.0 3.2-7), i get
> 
># telnet fe80::250:daff:fed2:d90e
> fe80::250:daff:fed2:d90e: Unknown host
> 
> In case, if i need to upgrade telnet, ftp, etc, suggest me where i
> can find them. Any docs for the same. looking forward for ur help

Grmmml, read FAQ in HowTo: do not use link-local addresses for normal
purposes, they won't work because of the scoping issue. Configure and
use site-local instead.

        Peter
-- 
Dr. Peter Bieringer                     http://www.bieringer.de/pb/
GPG/PGP Key 0x958F422D               mailto: pb at bieringer dot de 
Deep Space 6 Co-Founder and Core Member  http://www.deepspace6.net/
