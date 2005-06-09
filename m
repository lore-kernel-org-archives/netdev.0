From: Denis Vlasenko <vda@ilport.com.ua>
Subject: Re: ipw2100: firmware problem
Date: Thu, 9 Jun 2005 09:17:23 +0300
Message-ID: <200506090917.23853.vda@ilport.com.ua>
References: <42A7268D.9020402@linux.intel.com> <200506090903.49295.vda@ilport.com.ua> <20050608.231045.48808548.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: jketreno@linux.intel.com, pavel@ucw.cz, jgarzik@pobox.com,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org,
        ipw2100-admin@linux.intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050608.231045.48808548.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thursday 09 June 2005 09:10, David S. Miller wrote:
> From: Denis Vlasenko <vda@ilport.com.ua>
> Date: Thu, 9 Jun 2005 09:03:49 +0300
> 
> > You practically cannot avoid having initrd because you are very likely
> > to need to do some wifi config (at least ESSID and mode).
> 
> I need neither at home.  It comes up by default just fine with
> ifconfig.
> 
> Your points are valid, but they do not detract from the fact that
> pieced up drivers, half in the kernel half somewhere else, is total
> madness.  It is a lose for the user.

Here I am totally agree. I would like to not have to mess with
separate firmware files. I even don't want binary firmware, gimme
the source!

Sadly, realities are such that we have to live somehow
with closed-source firmware. Worse, sometimes it even isn't freely
redistributable (vendor did not explicitly allowed that),
and thus we have to ship driver, but users must obtain
firmware elsewhere themself.

Thus so far we cannot avoid having split drivers.
--
vda
