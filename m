From: Dave Hansen <haveblue@us.ibm.com>
Subject: RE: e1000 performance hack for ppc64 (Power4)
Date: 16 Jun 2003 11:30:29 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1055788229.1609.4.camel@nighthawk>
References: <C6F5CF431189FA4CBAEC9E7DD5441E010107D94C@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herman Dierks <hdierks@us.ibm.com>, "David S. Miller" <davem@redhat.com>,
   ltd@cisco.com, Anton Blanchard <anton@samba.org>, dwg@au1.ibm.com,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   Nancy J Milliner <milliner@us.ibm.com>,
   Ricardo C Gonzalez <ricardoz@us.ibm.com>,
   Brian Twichell <twichell@us.ibm.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Feldman, Scott" <scott.feldman@intel.com>
In-Reply-To: <C6F5CF431189FA4CBAEC9E7DD5441E010107D94C@orsmsx402.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2003-06-16 at 11:21, Feldman, Scott wrote:
> Herman wrote:
> > Its only the MTU 1500 case with non-TSO that we are 
> > discussing here so copying a few bytes is really not a big 
> > deal as the data is already in cache from copying into 
> > kernel.  If it lets the adapter run at speed, thats what 
> > customers want and what we need. Granted, if the HW could 
> > deal with this we would not have to, but thats not the case 
> > today so I want to spend a few CPU cycles to get best 
> > performance. Again, if this is not done on other platforms, I 
> > don't understand why you care.
> 
> I care because adding the arch-specific hack creates a maintenance issue
> for 

Scott, would you be pleased if something was implemented out of the
driver, in generic net code?  Something that all the drivers could use,
even if nothing but e1000 used it for now.

-- 
Dave Hansen
haveblue@us.ibm.com
