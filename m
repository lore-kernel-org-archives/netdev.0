From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [RFT 2/3] 8139cp: don't mix software and chip stats
Date: Wed, 16 Mar 2005 15:46:15 -0800
Message-ID: <20050316154615.4ac080c2@dxpl.pdx.osdl.net>
References: <20050316150431.6888fe55@dxpl.pdx.osdl.net>
	<20050316234202.GB27664@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20050316234202.GB27664@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 17 Mar 2005 00:42:02 +0100
Francois Romieu <romieu@fr.zoreil.com> wrote:

> Stephen Hemminger <shemminger@osdl.org> :
> > The rx_frags statistic is a software statistic and not a hardware statistic
> > and it is pasted on to the end. Since the statistic is really a warning about
> > overlength frames, it shouldn't be in the ethtool stats.  
> > 
> > Francois, could you make sure 8169 and 8139cp report fragments the same way.
> 
> (not sure I understood the question)

I just want frag handling to be similar in both driver since they both
have the same underlying chipset.  The stats should be the same, and any error
recovery should be similar.

Longer term, maybe the "grand unified phy" theory will allow making one driver
with different PHY support.
