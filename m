From: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v9 0/8] thunderbolt: Introducing Thunderbolt(TM)
 Networking
Date: Mon, 21 Nov 2016 13:22:41 +0100
Message-ID: <20161121122241.GA16158@kroah.com>
References: <1478701208-4585-1-git-send-email-amir.jer.levy@intel.com>
 <20161109143632.GE6167@kw.sim.vm.gnt>
 <E607265CB020454880711A6F96C05A03B677E4C9@hasmsx107.ger.corp.intel.com>
 <20161115105920.GH6167@kw.sim.vm.gnt>
 <E607265CB020454880711A6F96C05A03BE2199EE@hasmsx108.ger.corp.intel.com>
 <20161118100700.GA7126@kroah.com>
 <E607265CB020454880711A6F96C05A03BE2214E2@hasmsx107.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Simon Guinot <simon.guinot@sequanux.org>,
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
To: "Levy, Amir (Jer)" <amir.jer.levy@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:52640 "EHLO
        mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754255AbcKUMWc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 07:22:32 -0500
Content-Disposition: inline
In-Reply-To: <E607265CB020454880711A6F96C05A03BE2214E2@hasmsx107.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 20, 2016 at 06:30:19AM +0000, Levy, Amir (Jer) wrote:
> On Fri, Nov 18 2016, 12:07 PM, gregkh@linuxfoundation.org wrote:
> > On Fri, Nov 18, 2016 at 08:48:36AM +0000, Levy, Amir (Jer) wrote:
> > > > BTW, it is quite a shame that the Thunderbolt firmware version can't
> > > > be read from Linux.
> > > >
> > >
> > > This is WIP, once this patch will be upstream, we will be able to
> > > focus more on aligning Linux with the Thunderbolt features that we have
> > for windows.
> > 
> > Why is this patch somehow holding that work back?  You aren't just sitting
> > around waiting for people to review this and not doing anything else, right?
> > Is there some basic building block in these patches that your firmware
> > download code is going to rely on?
> > 
> > confused,
> > 
> > greg k-h
> 
> All the Thunderbolt SW features (including networking and FW update) depend 
> on the communication with FW, which is patch 3/8 in the series.
> The patch also sets up a generic netlink for user space communication.

It's that "generic netlink" connection that I really want a whole lot of
revewers to read over as it's very unusual and "different" from all
other driver subsystems.

thanks,

greg k-h
