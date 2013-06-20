From: "Nelson, Shannon" <shannon.nelson@intel.com>
Subject: Re: [net-next 3/8] i40e: driver ethtool core
Date: Thu, 20 Jun 2013 20:53:47 +0000
Message-ID: <FC41C24E35F18A40888AACA1A36F3E4168533FAC@FMSMSX102.amr.corp.intel.com>
References: <1371182122-26629-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1371182122-26629-4-git-send-email-jeffrey.t.kirsher@intel.com>
	<20130619114112.3cda715e@samsung-9>
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
In-Reply-To: <20130619114112.3cda715e@samsung-9>
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
> Sent: Wednesday, June 19, 2013 11:41 AM
> 
> On Thu, 13 Jun 2013 20:55:17 -0700
> Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:
> 
> > +
> > +static int i40e_get_eeprom_len(struct net_device *netdev)
> > +{
> > +	return 0;
> > +}
> > +
> > +static int i40e_get_eeprom(struct net_device *netdev,
> > +			   struct ethtool_eeprom *eeprom, u8 *bytes)
> > +{
> > +	return 0;
> > +}
> > +
> > +static int i40e_set_eeprom(struct net_device *netdev,
> > +			   struct ethtool_eeprom *eeprom, u8 *bytes)
> > +{
> > +	return -EOPNOTSUPP;
> > +}
> 
> No EEPROM, then just leave out the handlers.
> No need for stubs here.

Yep - thanks again,
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
