From: Jan Kasprzak <kas@fi.muni.cz>
Subject: Re: [patch 06/18]  net/cosa: replace 	schedule_timeout() with msleep_interruptible()
Date: Mon, 1 Nov 2004 12:23:14 +0100
Message-ID: <20041101112313.GD12416@fi.muni.cz>
References: <E1CO1vg-00027C-CO@sputnik> <4184C79F.3090602@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: janitor@sternwelten.at, netdev@oss.sgi.com, nacc@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <4184C79F.3090602@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
: why add all the memory barriers and such associated with 
: set_current_state() ?
: 
	This is not time-critical - COSA is an ISA-only device,
and the driver is not tested on SMP (I have tried to make it SMP-aware,
but at the time I had no SMP machine with ISA slot).

-Yenya

-- 
| Jan "Yenya" Kasprzak  <kas at {fi.muni.cz - work | yenya.net - private}> |
| GPG: ID 1024/D3498839      Fingerprint 0D99A7FB206605D7 8B35FCDE05B18A5E |
| http://www.fi.muni.cz/~kas/   Czech Linux Homepage: http://www.linux.cz/ |
> Whatever the Java applications and desktop dances may lead to, Unix will <
> still be pushing the packets around for a quite a while.      --Rob Pike <
