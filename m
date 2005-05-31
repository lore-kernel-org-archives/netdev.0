From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: TG3 fix for slow switches (Was: TG3 driver failure on HP
 16-way)
Date: Tue, 31 May 2005 11:22:52 -0700
Message-ID: <1117563772.4310.30.camel@rh4>
References: <B1508D50A0692F42B217C22C02D84972020F3CED@NT-IRVA-0741.brcm.ad.broadcom.com>
 <20050531153819.GA20793@esmail.cup.hp.com>
 <1117560157.4310.16.camel@rh4>
 <20050531183653.GF20793@esmail.cup.hp.com>
 <1117561365.4310.22.camel@rh4>
 <20050531190345.GH20793@esmail.cup.hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        "Peter Chubb" <peterc@gelato.unsw.edu.au>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Grant Grundler" <iod00d@hp.com>
In-Reply-To: <20050531190345.GH20793@esmail.cup.hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2005-05-31 at 12:03 -0700, Grant Grundler wrote:
> On Tue, May 31, 2005 at 10:42:45AM -0700, Michael Chan wrote:
> > No, I mean I will create a patch that will work for older devices that
> > do not have the valid LED bits in eeprom.
> 
> Ah ok. How can you know if the LED bits are valid (or not)?
> 

There are version numbers and signatures that we may be able to use. I
am working with the firmware engineer to see if we can find a way.

> I consider this a bug in the eeprom and have set things in motion
> (in HP) to correct it since the card is not an obsolete product.
> 
> Otherwise, the patch I submitted should be sufficient.
> 

I am hoping to have a patch that will work for all older devices instead
of just checking for subvendor IDs, if possible. If not, we'll go with
your patch.
