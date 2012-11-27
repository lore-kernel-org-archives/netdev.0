From: Mary Mcgrath <mary.mcgrath@oracle.com>
Subject: Re: 82571EB: Detected Hardware Unit Hang
Date: Mon, 26 Nov 2012 18:06:45 -0800 (PST)
Message-ID: <b46b84cf-3688-4fd7-b741-4e96f2663517@default>
References: <509B5038.8090304@oracle.com>
	<061C8A8601E8EE4CA8D8FD6990CEA89133487884@ORSMSX102.amr.corp.intel.com>
	<50A30656.6090508@oracle.com>
	<061C8A8601E8EE4CA8D8FD6990CEA8913348B105@ORSMSX102.amr.corp.intel.com>
	<50A43828.6000702@oracle.com>
	<061C8A8601E8EE4CA8D8FD6990CEA8913349A0B4@ORSMSX102.amr.corp.intel.com>
	<50A9C5CC.1030300@oracle.com>
	<061C8A8601E8EE4CA8D8FD6990CEA8913349EB41@ORSMSX102.amr.corp.intel.com>
	<50AB8471.7080607@oracle.com>
	<9B4A1B1917080E46B64F07F2989DADD62F2D62D6@ORSMSX102.amr.corp.intel.com>
	<50B41077.3080009@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sf.net,
	linux-kernel@vger.kernel.org
To: Joe Jin <joe.jin@oracle.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <50B41077.3080009@oracle.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Joe
Thank you for working this.
I would love to find out how they expect a customer to make the modification
To  "word  0x1A, and see if the 8th bit is 0 or 1, and to change to 0."

I have in turn asked the ct for the lspci command on eth3, maybe the incorrect setting is upstream.

Again,  thank you.
Regards
Mary



-----Original Message-----
From: Joe Jin 
Sent: Monday, November 26, 2012 8:00 PM
To: Fujinaka, Todd
Cc: Dave, Tushar N; netdev@vger.kernel.org; e1000-devel@lists.sf.net; linux-kernel@vger.kernel.org; Mary Mcgrath
Subject: Re: [E1000-devel] 82571EB: Detected Hardware Unit Hang

On 11/27/12 00:23, Fujinaka, Todd wrote:
> If you look at the previous section, DevCap, you'll see that it's 
> correctly advertising 256 bytes but the system is negotiating 128 for 
> the link to the Ethernet controller. Things on the "other" side of the 
> link are controlled outside of the e1000 driver.
> 
> Tushar's first suggestion was to check the PCIe payload settings in 
> the entire chain. Have you done that? Mismatches will cause hangs.

Hi Todd,

So far I had to know how to modify the maxpayload size, since BIOS have not entry to change this, so I had to use ethtool, now I need to get the offset of MaxPayload size in eeprom, I ever tried to find from Intel online document but failed, any idea?

Thanks in advance,
Joe

------------------------------------------------------------------------------
Monitor your physical, virtual and cloud infrastructure from a single
web console. Get in-depth insight into apps, servers, databases, vmware,
SAP, cloud infrastructure, etc. Download 30-day Free Trial.
Pricing starts from $795 for 25 servers or applications!
http://p.sf.net/sfu/zoho_dev2dev_nov
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
