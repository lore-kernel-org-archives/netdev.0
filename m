From: Peter Bieringer <pb@bieringer.de>
Subject: Re: Linux and Wake-On-Lan
Date: Wed, 07 May 2003 23:15:34 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <112220000.1052342133@gate.muc.bieringer.de>
References: <20030507090530.91065.qmail@web9703.mail.yahoo.com>
 <20030507.010630.48509535.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lucas75it@yahoo.it, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030507.010630.48509535.davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



--On Wednesday, May 07, 2003 01:06:30 AM -0700 "David S. Miller"
<davem@redhat.com> wrote:

>    From: Gianluca Masone <lucas75it@yahoo.it>
>    Date: Wed, 7 May 2003 11:05:30 +0200 (CEST)
> 
>    Suppose i put a net device in wake-on-lan status.
>    There is some kernel function that notifies presence
>    of a wake packet ?
> 
> This is not how wake-on-lan works.
> 
> When your computer is put to sleep (via APM or ACPI),
> the network card can listen for the wake packets.
> 
> If it is listening and a wakeup packet is received, your computer
> wakes up from sleep state.
> 
> All of this happens in the hardware, all Linux can do is
> enable/disable the feature.

That's right, but afair at least one driver has problems with this.
It's here not working with the eepro100 driver. The e100 works.

See here for more details:
https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=84695

        Peter
-- 
Dr. Peter Bieringer                     http://www.bieringer.de/pb/
GPG/PGP Key 0x958F422D               mailto: pb at bieringer dot de 
Deep Space 6 Co-Founder and Core Member  http://www.deepspace6.net/
