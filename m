From: Henrique de Moraes Holschuh <hmh@hmh.eng.br>
Subject: Re: 82571EB: Detected Hardware Unit Hang
Date: Mon, 16 Jul 2012 13:08:07 -0300
Message-ID: <20120716160807.GB1765@khazad-dum.debian.net>
References: <4FFE6BB9.4060106@oracle.com>
	<061C8A8601E8EE4CA8D8FD6990CEA891274F033B@ORSMSX102.amr.corp.intel.com>
	<4FFE787B.9050201@oracle.com>
	<061C8A8601E8EE4CA8D8FD6990CEA891274F0ACC@ORSMSX102.amr.corp.intel.com>
	<4FFF61BD.1060604@oracle.com>
	<061C8A8601E8EE4CA8D8FD6990CEA891274F11FF@ORSMSX102.amr.corp.intel.com>
	<4FFFA532.1030208@oracle.com>
	<061C8A8601E8EE4CA8D8FD6990CEA891274F2354@ORSMSX102.amr.corp.intel.com>
	<20120715133510.GA5484@khazad-dum.debian.net>
	<1342453645.2523.17.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sf.net" <e1000-devel@lists.sf.net>,
	Joe Jin <joe.jin@oracle.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <1342453645.2523.17.camel@bwh-desktop.uk.solarflarecom.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Mon, 16 Jul 2012, Ben Hutchings wrote:
> On Sun, 2012-07-15 at 10:35 -0300, Henrique de Moraes Holschuh wrote:
> > On Sun, 15 Jul 2012, Dave, Tushar N wrote:
> > > Somehow setting max payload to 256 from BIOS does not set this value for all devices. I believe this is a BIOS bug.
> > 
> > And preferably, Linux should complain about it.  Since we know it is going
> > to cause problems, and since we know it does happen, we should be raising a
> > ruckus about it in the kernel log (and probably fixing it to min(path) while
> > at it)...
> > 
> > Is this something that should be raised as a feature request with the
> > PCI/PCIe subsystem?
> 
> The feature is there, but we ended up with:
> 
> commit 5f39e6705faade2e89d119958a8c51b9b6e2c53c
> Author: Jon Mason <mason@myri.com>
> Date:   Mon Oct 3 09:50:20 2011 -0500
> 
>     PCI: Disable MPS configuration by default
> 
> But you are welcome to share use of the fixup_mpss_256() quirk.

Meh.  I'd be happy with a warning if MPSS decreases when walking up to
the tree root... i.e. a warning if any child has a MPSS larger than the
parent.

-- 
  "One disk to rule them all, One disk to find them. One disk to bring
  them all and in the darkness grind them. In the Land of Redmond
  where the shadows lie." -- The Silicon Valley Tarot
  Henrique Holschuh

------------------------------------------------------------------------------
Live Security Virtual Conference
Exclusive live event will cover all the ways today's security and 
threat landscape has changed and how IT managers can respond. Discussions 
will include endpoint security, mobile security and the latest in malware 
threats. http://www.accelacomm.com/jaw/sfrnl04242012/114/50122263/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
