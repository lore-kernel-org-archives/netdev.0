From: Roger Luethi <rl@hellgate.ch>
Subject: Re: via-rhine unable to send back-to-back packets?
Date: Thu, 2 Dec 2004 12:01:20 +0100
Message-ID: <20041202110120.GA16597@k3.hellgate.ch>
References: <20041129222700.GA22918@xi.wantstofly.org> <20041129172540.6b959858.davem@davemloft.net> <20041130064823.GA27872@xi.wantstofly.org> <20041130122503.0adac947.davem@davemloft.net> <20041130220644.GC29947@k3.hellgate.ch> <20041201200148.GE14470@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Content-Disposition: inline
In-Reply-To: <20041201200148.GE14470@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[Thanks to A.J. from VNT for the answer which I am relaying below.]

On Wed, 01 Dec 2004 21:01:48 +0100, Lennert Buytenhek wrote:
> "Is the hardware capable of sending back-to-back packets (i.e. with
> an inter-packet gap of no more than 96 bit times)?"

 => YES. All the VIA Rhine Fast Ethernet controllers follows the IEEE
standard (inter-frame gap is 96 bit time) and it is hardware fixed and
NOT programmable.

> "Can misprogramming the chip lead to the effect that the inter-packet
> gap is never less than 112 bit times?"

 => NO, it is fixed and neither software nor board level change could
modify the inter-frame gap of VIA Rhine Fast Ethernet controller.

> > Of course, you can always check if VIA's driver has the same issue. If
> > it doesn't, chances are we can borrow the fix.
> 
> Hmm, didn't know they had such a driver.  Where can I find it?

 => in http://www.viaarena.com/ , choose "downloads" => "Drivers" =>
choose target OS (e.g. Fedora Core Linux) => "Ethernet (Networking/LAN)"
=> choose the type of your Ethernet controller => click to download
the combo driver software package.
