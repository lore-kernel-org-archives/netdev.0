From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: RFC: NAPI packet weighting patch
Date: Fri, 3 Jun 2005 16:12:10 -0500
Message-ID: <200506031612.10456.jdmason@us.ibm.com>
References: <20050603.120126.41874584.davem@davemloft.net> <1117828771.6071.77.camel@localhost.localdomain> <20050603.133133.38710501.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, mitch.a.williams@intel.com, john.ronciak@intel.com,
        shemminger@osdl.org, netdev@oss.sgi.com, Robert.Olsson@data.slu.se,
        ganesh.venkatesan@intel.com, jesse.brandeburg@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050603.133133.38710501.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Friday 03 June 2005 03:31 pm, David S. Miller wrote:
> From: jamal <hadi@cyberus.ca>
> Date: Fri, 03 Jun 2005 15:59:31 -0400
>
> > But one that you could validate by putting proper hooks. As an example,
> > try to restore a descriptor every time you pick one - for an example of
> > this look at the sb1250 driver.
>
> Yes, this in my mind is exactly the problem.  TG3 does this
> properly, as do several other drivers.
>
> You should never defer RX buffer replenishment, you should
> always do it as you grab packets off of the ring.  You will
> starve the chip otherwise.

e1000 isn't the only driver to do things this way.  r8169, via-velocity, dl2k, 
and skge (and I'm sure many more).  Might be nice to perform a driver audit 
to see what drivers do this.
  
