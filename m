From: "Nelson, Shannon" <shannon.nelson@intel.com>
Subject: RE: [net-next 10/17] i40e: clean up PTP log messages
Date: Thu, 15 Jan 2015 22:44:48 +0000
Message-ID: <FC41C24E35F18A40888AACA1A36F3E418ADD4215@fmsmsx115.amr.corp.intel.com>
References: <1421324368-6860-11-git-send-email-jeffrey.t.kirsher@intel.com>
	<063D6719AE5E284EB5DD2968C1650D6D1CAC9AB0@AcuExch.aculab.com>
	<FC41C24E35F18A40888AACA1A36F3E418ADD011A@fmsmsx115.amr.corp.intel.com>
 <20150115.153846.1450539700341201746.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David.Laight@ACULAB.COM" <David.Laight@ACULAB.COM>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>,
	"Keller, Jacob E" <jacob.e.keller@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:24238 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752328AbbAOWou convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 17:44:50 -0500
In-Reply-To: <20150115.153846.1450539700341201746.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, January 15, 2015 12:39 PM
> 
> From: "Nelson, Shannon" <shannon.nelson@intel.com>
> Date: Thu, 15 Jan 2015 15:01:42 +0000
> 
> > The dev_info() messages have the PCI device and function number in the
> string, so it's really not too hard to track down the resulting netdev
> port:
> > Jan 13 15:46:55 snelson3-cup kernel: [621235.401627] i40e
> 0000:84:00.1: PHC enabled
> >
> > Later messages use netdev_info() and have both the device number and
> the netdev name:
> > Jan 13 15:46:56 snelson3-cup kernel: [621236.508868] i40e 0000:04:00.1
> p261p2: NIC Link is Up 10 Gbps Full Duplex, Flow Control: None
> >
> > Note that the driver name appears in both as well.
> 
> I think we should consistently provide the netdev name as soon as
> register_netdevice() returns.
> 
> It is unwise for every driver to have their own private policy on
> this.
> 
> Please change this back.

Sure, we can simply drop this patch.

<useless whine>
Yes, the driver should print the unvarnished truth.  What's frustrating about UDEV is that it ends up making the driver look like it is confused and/or lying in the log messages.  We'd prefer to minimize this unnecessary user-confusion where possible.
</useless whine>

sln
