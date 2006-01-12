From: Daniel Drake <dsd@gentoo.org>
Subject: pcnet32 devices with incorrect trident vendor ID
Date: Thu, 12 Jan 2006 20:49:42 +0000
Message-ID: <43C6C0E6.7030705@gentoo.org>
References: <20060112175051.GA17539@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mulix@mulix.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-pci@atrey.karlin.mff.cuni.cz
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161259AbWALUtx@vger.kernel.org>
To: Jon Mason <jdmason@us.ibm.com>
In-Reply-To: <20060112175051.GA17539@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jon Mason wrote:
> Some pcnet32 hardware erroneously has the Vendor ID for Trident.  The
> pcnet32 driver looks for the PCI ethernet class before grabbing the
> hardware, but the current trident driver does not check against the
> PCI audio class.  This allows the trident driver to claim the pcnet32 
> hardware.  This patch prevents that.

On the subject of pcnet32 and the invalid vendor ID, you may find this 
interesting:

http://forums.gentoo.org/viewtopic-t-420013-highlight-trident.html

The user saw the correct vendor ID (AMD) in 2.4, but when upgrading to 
2.6, it changed to Trident.

I guess this is still likely to be a hardware bug, but it demonstrates 
that the Linux PCI layer has something to do with it (even if it is just 
triggering it somehow).

Daniel
