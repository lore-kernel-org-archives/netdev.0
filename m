From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: via-rhine unable to send back-to-back packets?
Date: Thu, 2 Dec 2004 12:09:37 +0100
Message-ID: <20041202110937.GC24069@xi.wantstofly.org>
References: <20041129222700.GA22918@xi.wantstofly.org> <20041129172540.6b959858.davem@davemloft.net> <20041130064823.GA27872@xi.wantstofly.org> <20041130122503.0adac947.davem@davemloft.net> <20041130220644.GC29947@k3.hellgate.ch> <20041201200148.GE14470@xi.wantstofly.org> <20041202110120.GA16597@k3.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Roger Luethi <rl@hellgate.ch>
Content-Disposition: inline
In-Reply-To: <20041202110120.GA16597@k3.hellgate.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Dec 02, 2004 at 12:01:20PM +0100, Roger Luethi wrote:

> On Wed, 01 Dec 2004 21:01:48 +0100, Lennert Buytenhek wrote:
> > "Is the hardware capable of sending back-to-back packets (i.e. with
> > an inter-packet gap of no more than 96 bit times)?"
> 
>  => YES. All the VIA Rhine Fast Ethernet controllers follows the IEEE
> standard (inter-frame gap is 96 bit time) and it is hardware fixed and
> NOT programmable.

As far as I know, the IEEE standard only mandates a certain minimum
inter-frame gap.

Thanks for the information, I'll have a look at the VIA driver.


--L
