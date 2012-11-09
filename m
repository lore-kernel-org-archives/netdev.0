From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: SR-IOV problem with Intel 82599EB (not enough MMIO resources
 for SR-IOV)
Date: Fri, 9 Nov 2012 17:15:50 +0000
Message-ID: <C5551D9AAB213A418B7FD5E4A6F30A072D5683CF@ORSMSX106.amr.corp.intel.com>
References: <201211081915083774239@gmail.com>	<509B962C.6070002@gmail.com>
	<C5551D9AAB213A418B7FD5E4A6F30A072D565E76@ORSMSX106.amr.corp.intel.com>
 <CANmqhJDJXcbUxyt6YD6ktxZCDJ=VqiwhGXP+fLMukQr0o-XwxQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, kvm <kvm@vger.kernel.org>
To: Jason Gao <pkill.2012@gmail.com>, "Li, Sibai" <sibai.li@intel.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <CANmqhJDJXcbUxyt6YD6ktxZCDJ=VqiwhGXP+fLMukQr0o-XwxQ@mail.gmail.com>
Content-Language: en-US
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Jason Gao [mailto:pkill.2012@gmail.com]
> Sent: Thursday, November 08, 2012 8:00 PM
> To: Rose, Gregory V
> Cc: Kirsher, Jeffrey T; linux-kernel; netdev; kvm; e1000-
> devel@lists.sourceforge.net
> Subject: Re: SR-IOV problem with Intel 82599EB (not enough MMIO resources
> for SR-IOV)
> 
> > The BIOS in your machine doesn't support SR-IOV.  You'll need to ask the
> manufacturer for a BIOS upgrade, if in fact one is available.  Sometimes
> they're not.
> 
> very thanks Greg,my server Dell R710 with latest BIOS version and option
> for SR-IOV(SR-IOV Global Enable->Enabled)  opened,I'm confused that Does
> R710 provide full support for SR-IOV, kernel or  ixgbe driver's bug? but
> I'm not sure where the problem lies,anyone has any
> experience about this?   .

I use a Dell R710 for all my SR-IOV testing and it works fine but I had to acquire a special BIOS from Dell to get it to work.  As I said, you'll want to contact them and make sure you've got the correct BIOS.

The error you're seeing, "not enough MMIO resources" has been an issue with the BIOS 100% of the times that we've run into it.  In any case, it is NOT a driver bug.  The driver has nothing to do with allocation of MMIO space reservation for VF devices.  The message you're seeing pops up when the driver calls pci_enable_sriov().  There is nothing the driver can do to force that call to be successful.

I've added Sibai Li to this response.  She should be able to get the BIOS version string off of one of our working Dell R710s.

Sibai,

Could you please reply to this message with that information?

Thanks,

- Greg
