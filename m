From: Mika Westerberg <mika.westerberg@intel.com>
Subject: Re: [PATCH v8 3/8] thunderbolt: Communication with the ICM (firmware)
Date: Tue, 20 Dec 2016 10:09:16 +0200
Message-ID: <20161220080916.GV1460@lahna.fi.intel.com>
References: <1475073870-2126-1-git-send-email-amir.jer.levy@intel.com>
 <1475073870-2126-4-git-send-email-amir.jer.levy@intel.com>
 <fe0f0a6f-488b-bbc0-8987-a9c47d9ed9b9@kernel.org>
 <20161219122407.GQ1460@lahna.fi.intel.com>
 <05d9c1db67af410981bbb9672071a237@ausx13mpc120.AMER.DELL.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: luto@kernel.org, amir.jer.levy@intel.com,
        gregkh@linuxfoundation.org, andreas.noever@gmail.com,
        bhelgaas@google.com, corbet@lwn.net, linux-kernel@vger.kernel.org,
        linux-pci@vger.kernel.org, netdev@vger.kernel.org,
        linux-doc@vger.kernel.org, thunderbolt-linux@intel.com,
        tomas.winkler@intel.com, xiong.y.zhang@intel.com
To: Mario.Limonciello@dell.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <05d9c1db67af410981bbb9672071a237@ausx13mpc120.AMER.DELL.COM>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 19, 2016 at 05:21:39PM +0000, Mario.Limonciello@dell.com wrote:
> Dell - Internal Use - Confidential  
> 
> > 
> > There is small problem, though. On non-Apple systems the host controller only
> > appears when something is connected to thunderbolt ports. So the char device
> > would not be there all the time. However, I think we can still notify the
> > userspace by sending an extra uevent when we detect there is a PCIe device or
> > inter-domain connection plugged in.
> > 
> 
> Why couldn't you just create it the first time a device is plugged into a Thunderbolt
> port and leave it until the module is cleaned up?  If the host controller goes to sleep
> an event could be sent to the daemon to let it know it disappeared and not to expect
> data on the char device for now, but leave the node around. 

We don't do that for USB memory sticks (or any other removable media)
either - once you disconnect the device the nodes are also removed. I
suppose same goes with USB network adapters, which is closest to
thunderbolt networking I can think of.
