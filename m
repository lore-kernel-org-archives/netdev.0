From: Chris Adams <cmadams@hiwaay.net>
Subject: Re: Problem with Compaq NC3131 dual eth card
Date: Tue, 6 Jan 2004 22:18:46 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040107041845.GA1446903@hiwaay.net>
References: <C6F5CF431189FA4CBAEC9E7DD5441E0102CBDDAF@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <C6F5CF431189FA4CBAEC9E7DD5441E0102CBDDAF@orsmsx402.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Once upon a time, Feldman, Scott <scott.feldman@intel.com> said:
> You're EEPROM image is invalid - looks like it's all 0xFFs - verify with
> ethtool -e ethX.  The first three words of the EEPROM should be the MAC
> address.  e100 errors out because it wants a valid MAC address.

Yep, all 1s.

> > Is my card defective or is this a compatibility problem?  Is 
> > there a way to fix this?
> 
> Get another nic or reprogram the EEPROM in this one.
<snip>

I looked at some other Intel NICs here and kind of winged it; I
reprogrammed both EEPROMs, made up a couple of MACs, and it is working
now.

Thanks.  Not bad for a $20 card picked up at a general surplus store
here.  It was still sealed in the box (Compaq labels on both box flaps,
sealed static bag, etc.), so it must have come that way from Compaq.
Maybe they had a bad batch and surplused them instead of fixing them?
Now I might have to go back and pick up some more! :-)
-- 
Chris Adams <cmadams@hiwaay.net>
Systems and Network Administrator - HiWAAY Internet Services
I don't speak for anybody but myself - that's enough trouble.
