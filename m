From: Rask Ingemann Lambertsen <rask@sygehus.dk>
Subject: Re: hw tcp v4 csum failed on 2.4.23-rc2 with e100
Date: Wed, 26 Nov 2003 01:04:00 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031126010359.B1264@sygehus.dk>
References: <3FBDE9BF.2070909@allot.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Felix Radensky <felix@allot.com>
Content-Disposition: inline
In-Reply-To: <3FBDE9BF.2070909@allot.com>; from felix@allot.com on Fri, Nov 21, 2003 at 12:32:31PM +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Nov 21, 2003 at 12:32:31PM +0200, Felix Radensky wrote:
> Hi,
> 
> I keep getting tons of this messages with 2.4.23-rc2
> and e100 driver:
> 
> hw tcp v4 csum failed
> hw tcp v4 csum failed

I just got (e100 with i82559, kernel 2.4.22-bk45)

Nov 25 23:17:13 linddaase kernel: udp v4 hw csum failure.
Nov 25 23:20:51 linddaase kernel: udp v4 hw csum failure.
Nov 25 23:26:59 linddaase kernel: udp v4 hw csum failure.
Nov 25 23:26:59 linddaase kernel: UDP: bad checksum. From 130.233.41.46:47064 to 80.161.68.244:1026 ulen 421

while playing XPilot on kallio.cs.hut.fi. Two false alarms and one real
checksum failure. What the deal is with the false alarms is a good question
since no useful information about the packets is logged.

-- 
Regards,
Rask Ingemann Lambertsen
