From: "Nelson, Shannon" <shannon.nelson@intel.com>
Subject: Re: [net-next 3/8] i40e: driver ethtool core
Date: Thu, 20 Jun 2013 20:52:46 +0000
Message-ID: <FC41C24E35F18A40888AACA1A36F3E4168533F93@FMSMSX102.amr.corp.intel.com>
References: <1371182122-26629-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1371182122-26629-4-git-send-email-jeffrey.t.kirsher@intel.com>
	<20130619113825.45cc7f32@samsung-9>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Brandeburg,
	Jesse" <jesse.brandeburg@intel.com>, "gospo@redhat.com" <gospo@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Stephen Hemminger <stephen@networkplumber.org>, "Kirsher, Jeffrey T"
	<jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20130619113825.45cc7f32@samsung-9>
Content-Language: en-US
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Stephen Hemminger [mailto:stephen@networkplumber.org]
> Sent: Wednesday, June 19, 2013 11:38 AM
> 
> On Thu, 13 Jun 2013 20:55:17 -0700
> Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:
> 
> > +static const struct i40e_stats i40e_gstrings_net_stats[] = {
> > +	I40E_NETDEV_STAT(rx_packets),
> > +	I40E_NETDEV_STAT(tx_packets),
> > +	I40E_NETDEV_STAT(rx_bytes),
> > +	I40E_NETDEV_STAT(tx_bytes),
> > +	I40E_NETDEV_STAT(rx_errors),
> > +	I40E_NETDEV_STAT(tx_errors),
> > +	I40E_NETDEV_STAT(rx_dropped),
> > +	I40E_NETDEV_STAT(tx_dropped),
> > +	I40E_NETDEV_STAT(multicast),
> > +	I40E_NETDEV_STAT(collisions),
> > +	I40E_NETDEV_STAT(rx_length_errors),
> > +	I40E_NETDEV_STAT(rx_over_errors),
> > +	I40E_NETDEV_STAT(rx_crc_errors),
> > +	I40E_NETDEV_STAT(rx_frame_errors),
> > +	I40E_NETDEV_STAT(rx_fifo_errors),
> > +	I40E_NETDEV_STAT(tx_aborted_errors),
> > +	I40E_NETDEV_STAT(tx_carrier_errors),
> > +	I40E_NETDEV_STAT(tx_fifo_errors),
> > +	I40E_NETDEV_STAT(tx_heartbeat_errors),
> > +	I40E_NETDEV_STAT(tx_window_errors),
> > +	I40E_NETDEV_STAT(rx_compressed),
> > +	I40E_NETDEV_STAT(tx_compressed),
> > +}
> 
> Why duplicate network device stats in ethtool stats?

Because the NETDEV_STATs are essentially a subset of the PF_STATs - see my answer to Ben for more details.

We'll try to add a little more commentary here to make it more clear.

sln


------------------------------------------------------------------------------
This SF.net email is sponsored by Windows:

Build for Windows Store.

http://p.sf.net/sfu/windows-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
