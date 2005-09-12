From: Bernd Schubert <bernd.schubert@pci.uni-heidelberg.de>
Subject: Re: skge: reboot on sysfs resource0 access
Date: Mon, 12 Sep 2005 13:01:39 +0200
Message-ID: <200509121301.39924.bernd.schubert@pci.uni-heidelberg.de>
References: <200509091938.18079.bernd.schubert@pci.uni-heidelberg.de> <20050909110153.5a2e2e90@localhost.localdomain> <4321D2C0.10800@candelatech.com>
Reply-To: bernd-schubert@gmx.de
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <4321D2C0.10800@candelatech.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> > Sorry, this is not a driver bug.
>
> Does that mean if you do this:
>
> find /sys -name "*" -print|xargs grep foo
>
> that the system will crash?

I would also guess it would happen, though I won't try that now.

>
> I certainly would consider that a bug, and even if that somehow works, I'd
> think that at the least you should be able to read every file in the file
> system without crashing the system!
>
> Do you at least have to be root to cause this crash?

Yes, the resource0 file has rw access to root only.


Cheers,
	Bernd
