From: Carl-Daniel Hailfinger <c-d.hailfinger.kernel.2004@gmx.net>
Subject: Re: A small forcedeth driver issue
Date: Tue, 10 Feb 2004 01:04:22 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40282006.2090508@gmx.net>
References: <200402092252.22540.kenneth.krekula@kiruna.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Kenneth Krekula <kenneth.krekula@kiruna.se>
In-Reply-To: <200402092252.22540.kenneth.krekula@kiruna.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Kenneth Krekula wrote:
> Hi.
> 
> I have a NForce1 motherboard and have tested the forcedeth driver with
> the Mandrake 10 betas. The driver works very well (thanks for the great
> work!!) and I only have a small issue:
> 
> If I have been using the driver in Mandrake 10 beta 2, and reboot into
> Win XP or Mandrake Linux 9.2 (with the NVIdia NForce drivers) the
> network just fails.

I assume it works fine if you reboot into Linux with forcedeth again, right?


> However, if I shut off the power switch and wait for some seconds, I
> can power on and boot into Win XP, Mandrake 9.2.
> 
> I don't know if this is a known issue or not.

Yes, it's a known issue. Basically, forcedeth does not shutdown the
hardware completely, but this should not matter if it is reinitialized
correctly during the next boot. forcedeth can reinitialize hardware even
if it wasn't shutdown completely. The windows driver, however, lacks this
feature and therefore fails.

There are two ways to deal with the issue:
- get a better windows driver (more recent versions from Nvidia *should* work)
- wait a few weeks until I get access to some nforce hardware and can fix
this.

I do not want to change the shutdown procedure without testing it on real
hardware. The last time I did that, I got a complete lockup.


HTH,
Carl-Daniel
-- 
http://www.hailfinger.org/
