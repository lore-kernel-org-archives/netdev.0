From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: e1000 performance hack for ppc64 (Power4)
Date: Mon, 16 Jun 2003 11:56:03 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E010107D94F@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: "Herman Dierks" <hdierks@us.ibm.com>, "David S. Miller" <davem@redhat.com>,
   <ltd@cisco.com>, "Anton Blanchard" <anton@samba.org>, <dwg@au1.ibm.com>,
   "Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
   "Nancy J Milliner" <milliner@us.ibm.com>,
   "Ricardo C Gonzalez" <ricardoz@us.ibm.com>,
   "Brian Twichell" <twichell@us.ibm.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "Dave Hansen" <haveblue@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Scott, would you be pleased if something was implemented out 
> of the driver, in generic net code?  Something that all the 
> drivers could use, even if nothing but e1000 used it for now.

I suppose the driver could unconditionally call something like
skb_realign_for_broken_hw, which is a nop on non-broken archs, but would
it make more sense to not have the driver mess with the skb at all?

-scott
