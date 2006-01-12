From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: pcnet32 devices with incorrect trident vendor ID
Date: Thu, 12 Jan 2006 13:57:14 -0700
Message-ID: <20060112205714.GK19769@parisc-linux.org>
References: <20060112175051.GA17539@us.ibm.com> <43C6C0E6.7030705@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jon Mason <jdmason@us.ibm.com>, mulix@mulix.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-pci@atrey.karlin.mff.cuni.cz
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161261AbWALU5P@vger.kernel.org>
To: Daniel Drake <dsd@gentoo.org>
Content-Disposition: inline
In-Reply-To: <43C6C0E6.7030705@gentoo.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 12, 2006 at 08:49:42PM +0000, Daniel Drake wrote:
> interesting:
> 
> http://forums.gentoo.org/viewtopic-t-420013-highlight-trident.html
> 
> The user saw the correct vendor ID (AMD) in 2.4, but when upgrading to 
> 2.6, it changed to Trident.

It looks to me like there used to be a quirk that knew about this bug
and fixed it.

The reason I say this is that the lspci -x dumps are the same -- both
featuring the wrong vendor ID.  Want to dig through 2.4 and look for
this quirk?
