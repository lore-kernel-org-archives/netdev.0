From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [net-next v2 13/15] i40e: limit WoL and link settings to
 partition 1
Date: Mon, 19 Jan 2015 06:09:49 +0000
Message-ID: <B5657A6538887040AD3A81F1008BEC63BC8FD3@avmb3.qlogic.org>
References: <1421179093-10932-1-git-send-email-jeffrey.t.kirsher@intel.com>,<1421179093-10932-14-git-send-email-jeffrey.t.kirsher@intel.com>
 <B5657A6538887040AD3A81F1008BEC63BC8933@avmb3.qlogic.org>,<FC41C24E35F18A40888AACA1A36F3E418ADD6433@fmsmsx115.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>
To: "Nelson, Shannon" <shannon.nelson@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:23263 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751398AbbASGJ6 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jan 2015 01:09:58 -0500
In-Reply-To: <FC41C24E35F18A40888AACA1A36F3E418ADD6433@fmsmsx115.amr.corp.intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > How can user be aware of this 'private' behavior?
> > via system logs? documentation?

> In this case, note that we have added a log message that
> says these are dependent on the initial partition of the port
> for setting control.  Also, the particular vendor using the 
> device in this configuration will supply and support the user documentation.

What I'm 'aiming' for is that this is a common problem;
I.e., having multiple PCI functions per a physical port is a constellation
which exists in several devices.

I think the community strives in such scenarios to uphold a unite front
for user experience - if the 'right' answer is that the network device
associated with the first PCI function is the configuration node in such
cases, then we should strive making it so for all drivers.

> > How does it interact with Physical Device Assignment of the first
> > partition?

> I'm not sure I understand this question, but I'll answer a different
> question: these multifunction ports show up as additional PCI
> functions, again, not unlike VF devices.

You can't refrain from user assigning the first partition to a VM.
In such a case, you receive quite a bizarre configuration when you
all a ~random device on some VM to control the physical port. 
