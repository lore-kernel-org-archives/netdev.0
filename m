From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] bonding/vlan: Avoid mangled NAs on slaves
 without VLAN tag insertion
Date: Wed, 16 Feb 2011 13:58:55 -0800
Message-ID: <20110216215855.GL5027@kroah.com>
References: <1297106455.4077.7.camel@bwh-desktop>
	<20110207.131754.59684095.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org, fubar@us.ibm.com,
        stable@kernel.org, bonding-devel@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <stable-bounces@linux.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110207.131754.59684095.davem@davemloft.net>
List-Unsubscribe: <http://linux.kernel.org/mailman/options/stable>,
	<mailto:stable-request@linux.kernel.org?subject=unsubscribe>
List-Archive: <http://linux.kernel.org/mailman/private/stable/>
List-Post: <mailto:stable@linux.kernel.org>
List-Help: <mailto:stable-request@linux.kernel.org?subject=help>
List-Subscribe: <http://linux.kernel.org/mailman/listinfo/stable>,
	<mailto:stable-request@linux.kernel.org?subject=subscribe>
Sender: stable-bounces@linux.kernel.org
Errors-To: stable-bounces@linux.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 07, 2011 at 01:17:54PM -0800, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Mon, 07 Feb 2011 19:20:55 +0000
> 
> > This is related to commit f88a4a9b65a6f3422b81be995535d0e69df11bb8
> > upstream, but the bug cannot be properly fixed without the other
> > changes to VLAN tagging in 2.6.37.
> > 
> > bond_na_send() attempts to insert a VLAN tag in between building and
> > sending packets of the respective formats.  If the slave does not
> > implement hardware VLAN tag insertion then vlan_put_tag() will mangle
> > the network-layer header because the Ethernet header is not present at
> > this point (unlike in bond_arp_send()).
> > 
> > Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> 
> Acked-by: David S. Miller <davem@davemloft.net>

Great, thanks for the patch, now queued up for the next .32-stable
release.

greg k-h
