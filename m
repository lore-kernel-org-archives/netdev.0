From: "Levy, Amir (Jer)" <amir.jer.levy@intel.com>
Subject: RE: [PATCH v9 0/8] thunderbolt: Introducing Thunderbolt(TM)
 Networking
Date: Fri, 18 Nov 2016 08:48:36 +0000
Message-ID: <E607265CB020454880711A6F96C05A03BE2199EE@hasmsx108.ger.corp.intel.com>
References: <1478701208-4585-1-git-send-email-amir.jer.levy@intel.com>
 <20161109143632.GE6167@kw.sim.vm.gnt>
 <E607265CB020454880711A6F96C05A03B677E4C9@hasmsx107.ger.corp.intel.com>
 <20161115105920.GH6167@kw.sim.vm.gnt>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
        "andreas.noever@gmail.com" <andreas.noever@gmail.com>,
        "bhelgaas@google.com" <bhelgaas@google.com>,
        "corbet@lwn.net" <corbet@lwn.net>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
        "mario_limonciello@dell.com" <mario_limonciello@dell.com>,
        thunderbolt-linux <thunderbolt-linux@intel.com>,
        "Westerberg, Mika" <mika.westerberg@intel.com>,
        "Winkler, Tomas" <tomas.winkler@intel.com>,
        "Zhang, Xiong Y" <xiong.y.zhang@intel.com>,
        "Jamet, Michael" <michael.jamet@intel.com>,
        "remi.rerolle@seagate.com" <remi.rerolle@seagate.com>
To: Simon Guinot <simon.guinot@sequanux.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20161115105920.GH6167@kw.sim.vm.gnt>
Content-Language: en-US
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 15 2016, 12:59 PM, Simon Guinot wrote:
> On Wed, Nov 09, 2016 at 03:42:53PM +0000, Levy, Amir (Jer) wrote:
> > On Wed, Nov 9 2016, 04:36 PM, Simon Guinot wrote:
> > > Hi Amir,
> > >
> > > I have an ASUS "All Series/Z87-DELUXE/QUAD" motherboard with a 
> > > Thunderbolt 2 "Falcon Ridge" chipset (device ID 156d).
> > >
> > > Is the thunderbolt-icm driver supposed to work with this chipset ?
> > >
> >
> > Yes, the thunderbolt-icm supports Falcon Ridge, device ID 156c.
> > 156d is the bridge -
> > http://lxr.free-electrons.com/source/include/linux/pci_ids.h#L2619
> >
> > > I have installed both a 4.8.6 Linux kernel (patched with your v9
> > > series) and the thunderbolt-software-daemon (27 october release) 
> > > inside a Debian system (Jessie).
> > >
> > > If I connect the ASUS motherboard with a MacBook Pro (Thunderbolt 
> > > 2, device ID 156c), I can see that the thunderbolt-icm driver is 
> > > loaded and that the thunderbolt-software-daemon is well started. 
> > > But the Ethernet interface is not created.
> > >
> > > I have attached to this email the syslog file. There is the logs 
> > > from both the kernel and the daemon inside. Note that the daemon 
> > > logs are everything but clear about what could be the issue. Maybe 
> > > I missed some kind of configuration ? But I failed to find any 
> > > valuable information about configuring the driver and/or the 
> > > daemon in
> the various documentation files.
> > >
> > > Please, can you provide some guidance ? I'd really like to test 
> > > your patch series.
> >
> > First, thank you very much for willing to test it.
> > Thunderbolt Networking support was added during Falcon Ridge, in the
> latest FR images.
> > Do you know which Thunderbolt image version you have on your system?
> > Currently I submitted only Thunderbolt Networking feature in Linux, 
> > and we plan to add more features like reading the image version and
> updating the image.
> > If you don't know the image version, the only thing I can suggest is 
> > to load windows, install thunderbolt SW and check in the Thunderbolt
> application the image version.
> > To know if image update is needed, you can check - 
> > https://thunderbolttechnology.net/updates
> 
> Hi Amir,
> 
> From the Windows Thunderbolt software, I can read 13.00 for the 
> firmware version. And from https://thunderbolttechnology.net/updates, 
> I can see that there is no update available for my ASUS motherboard.
> 
> Am I good to go ?
> 

Thunderbolt Networking is supported on both Thunderbolt(tm) 2 and Thunderbolt(tm) 3 systems.  
Thunderbolt 2 systems must have updated NVM (version 25 or later) in order for the functionality to work properly.  
If the system does not have the update, please contact the OEM directly for an updated NVM.  
For best functionality and support, Intel recommends using Thunderbolt 3 systems for all validation and testing.

> BTW, it is quite a shame that the Thunderbolt firmware version can't 
> be read from Linux.
> 

This is WIP, once this patch will be upstream, we will be able to focus more
on aligning Linux with the Thunderbolt features that we have for windows.

Regards,
Amir
