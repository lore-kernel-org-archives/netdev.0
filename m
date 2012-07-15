From: David Hagood <david.hagood@gmail.com>
Subject: Re: [RFC 1/2] PCI-Express Non-Transparent Bridge Support
Date: Sun, 15 Jul 2012 07:37:39 -0500
Message-ID: <1342355859.23866.17.camel@chumley>
References: <1342215900-3358-1-git-send-email-jon.mason@intel.com>
	 <20120713171344.1066d3b1@nehalam.linuxnetplumber.net>
	 <20120714061953.GD4808@jonmason-lab>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org, Dave Jiang <dave.jiang@intel.com>
To: Jon Mason <jon.mason@intel.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20120714061953.GD4808@jonmason-lab>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Have you looked at any of the work that the PXI group has done on NTB
support within PXI?
http://www.ni.com/white-paper/12523/en

I was on that working group, and one of the first capabilities I
suggested for it was IP over NTB - I was going to implement this at my
employer, but the project took a different turn and this idea got put on
the back burner. I am glad somebody else has seen fit to take it up.

Also, a stupid question but one I have to ask: have you taken into
account the idea that the CPUs on each side of the NTB might have
different endian-ness? I was looking at a case with a PPC on one side of
the bridge and an X86 on the other.
