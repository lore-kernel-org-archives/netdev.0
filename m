From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 06/18]  net/cosa: replace 	schedule_timeout() with msleep_interruptible()
Date: Mon, 1 Nov 2004 14:00:07 -0800
Message-ID: <20041101220007.GA4255@us.ibm.com>
References: <E1CO1vg-00027C-CO@sputnik> <4184C79F.3090602@pobox.com> <20041101112313.GD12416@fi.muni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, janitor@sternwelten.at,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jan Kasprzak <kas@fi.muni.cz>
Content-Disposition: inline
In-Reply-To: <20041101112313.GD12416@fi.muni.cz>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Nov 01, 2004 at 12:23:14PM +0100, Jan Kasprzak wrote:
> Jeff Garzik wrote:
> : why add all the memory barriers and such associated with 
> : set_current_state() ?
> : 
> 	This is not time-critical - COSA is an ISA-only device,
> and the driver is not tested on SMP (I have tried to make it SMP-aware,
> but at the time I had no SMP machine with ISA slot).

Just to make it clear, then, the current patch is ok? Or would you
prefer I had used __set_current_state()?

-Nish
