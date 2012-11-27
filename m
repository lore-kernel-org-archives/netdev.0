From: Joe Jin <joe.jin@oracle.com>
Subject: Re: [E1000-devel] 82571EB: Detected Hardware Unit Hang
Date: Tue, 27 Nov 2012 08:59:35 +0800
Message-ID: <50B41077.3080009@oracle.com>
References: <509B5038.8090304@oracle.com> <061C8A8601E8EE4CA8D8FD6990CEA89133487884@ORSMSX102.amr.corp.intel.com> <50A30656.6090508@oracle.com> <061C8A8601E8EE4CA8D8FD6990CEA8913348B105@ORSMSX102.amr.corp.intel.com> <50A43828.6000702@oracle.com> <061C8A8601E8EE4CA8D8FD6990CEA8913349A0B4@ORSMSX102.amr.corp.intel.com> <50A9C5CC.1030300@oracle.com> <061C8A8601E8EE4CA8D8FD6990CEA8913349EB41@ORSMSX102.amr.corp.intel.com> <50AB8471.7080607@oracle.com> <9B4A1B1917080E46B64F07F2989DADD62F2D62D6@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Dave, Tushar N" <tushar.n.dave@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sf.net" <e1000-devel@lists.sf.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Mary Mcgrath <mary.mcgrath@oracle.com>
To: "Fujinaka, Todd" <todd.fujinaka@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <9B4A1B1917080E46B64F07F2989DADD62F2D62D6@ORSMSX102.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/27/12 00:23, Fujinaka, Todd wrote:
> If you look at the previous section, DevCap, you'll see that it's
> correctly advertising 256 bytes but the system is negotiating 128 for
> the link to the Ethernet controller. Things on the "other" side of the
> link are controlled outside of the e1000 driver.
> 
> Tushar's first suggestion was to check the PCIe payload settings in the
> entire chain. Have you done that? Mismatches will cause hangs.

Hi Todd,

So far I had to know how to modify the maxpayload size, since BIOS have not
entry to change this, so I had to use ethtool, now I need to get the offset
of MaxPayload size in eeprom, I ever tried to find from Intel online document
but failed, any idea?

Thanks in advance,
Joe
