From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [RFC] [PATCH 0/3] ioat: DMA engine support
Date: Thu, 08 Dec 2005 22:42:19 +0000
Message-ID: <1134081739.17102.79.camel@localhost.localdomain>
References: <Pine.LNX.4.44.0512081606060.24134-100000@gate.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Andrew Grover <andrew.grover@intel.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	john.ronciak@intel.com, christopher.leech@intel.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932687AbVLHWnP@vger.kernel.org>
To: Kumar Gala <galak@gate.crashing.org>
In-Reply-To: <Pine.LNX.4.44.0512081606060.24134-100000@gate.crashing.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Iau, 2005-12-08 at 16:13 -0600, Kumar Gala wrote:
> I'm actually searching for any examples of drivers that deal with the 
> issues related to DMA'ng directly two and from user space memory.

Look at drivers/media/video for several examples. Essentially in 2.6
get_user_pages() gives you page structs and pins the pages you need.
