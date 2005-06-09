From: Andi Kleen <ak@muc.de>
Subject: Re: ipw2100: firmware problem
Date: Thu, 09 Jun 2005 15:56:15 +0200
Message-ID: <m1is0nvdkw.fsf@muc.de>
References: <20050608142310.GA2339@elf.ucw.cz>
	<42A723D3.3060001@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, Netdev list <netdev@oss.sgi.com>,
	kernel list <linux-kernel@vger.kernel.org>,
	"James P. Ketrenos" <ipw2100-admin@linux.intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262349AbVFIN4W@vger.kernel.org>
To: James Ketrenos <jketreno@linux.intel.com>
In-Reply-To: <42A723D3.3060001@linux.intel.com> (James Ketrenos's message of
 "Wed, 08 Jun 2005 11:58:59 -0500")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Ketrenos <jketreno@linux.intel.com> writes:
>>
> We've been looking into whether the initrd can have the firmware affixed
> to the end w/ some magic bytes to identify it.  If it works, enhancing
> the request_firmware to support both hotplug and an initrd approach may
> be reasonable.

That space is already used in common distributions for replacement DSDTs

I guess at some point we will need a file system in there, but - oops -
we already have one, dont we? :)

-Andi
