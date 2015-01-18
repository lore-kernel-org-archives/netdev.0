From: "Nelson, Shannon" <shannon.nelson@intel.com>
Subject: RE: [net-next v2 13/15] i40e: limit WoL and link settings to
 partition 1
Date: Sun, 18 Jan 2015 23:26:03 +0000
Message-ID: <FC41C24E35F18A40888AACA1A36F3E418ADD6433@fmsmsx115.amr.corp.intel.com>
References: <1421179093-10932-1-git-send-email-jeffrey.t.kirsher@intel.com>,<1421179093-10932-14-git-send-email-jeffrey.t.kirsher@intel.com>
 <B5657A6538887040AD3A81F1008BEC63BC8933@avmb3.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:6186 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751175AbbARX0G convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2015 18:26:06 -0500
In-Reply-To: <B5657A6538887040AD3A81F1008BEC63BC8933@avmb3.qlogic.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Yuval Mintz [mailto:Yuval.Mintz@qlogic.com]
> Sent: Saturday, January 17, 2015 10:10 PM
> 
> >From: Shannon Nelson <shannon.nelson@intel.com>
> 
> >When in multi-function mode, e.g. Dell's NPAR, only partition 1
> >of each MAC is allowed to set WoL, speed, and flow control.
> 
> Isn't it problematic? I mean, in bnx2x we address ~same issue -
> but due to symmetry we prevent ALL interfaces from changing
> the link configuration.

Yes, this multi-function hardware port makes for "interesting opportunities" in hardware configuration.  In our case, our requirements are to still allow for configuration of the hardware port.  This is not unlike how a PF controls the physical port for its VF devices.

> 
> How can user be aware of this 'private' behavior? via system logs?
> documentation?

In this case, note that we have added a log message that says these are dependent on the initial partition of the port for setting control.  Also, the particular vendor using the device in this configuration will supply and support the user documentation.

> 
> How does it interact with Physical Device Assignment of the first
> partition?

I'm not sure I understand this question, but I'll answer a different question: these multifunction ports show up as additional PCI functions, again, not unlike VF devices.

> 
> Cheers,
> Yuval

sln
