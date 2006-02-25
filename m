From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [Announce] Intel PRO/Wireless 3945ABG Network Connection
Date: Sat, 25 Feb 2006 08:41:39 +0000
Message-ID: <20060225084139.GB22109@infradead.org>
References: <43FF88E6.6020603@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NetDev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org,
	okir@suse.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932599AbWBYIll@vger.kernel.org>
To: James Ketrenos <jketreno@linux.intel.com>
Content-Disposition: inline
In-Reply-To: <43FF88E6.6020603@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 24, 2006 at 04:29:58PM -0600, James Ketrenos wrote:
> As a result of this change, some of the capabilities currently required
> to be provided on the host include enforcement of regulatory limits for
> the radio transmitter (radio calibration, transmit power, valid
> channels, 802.11h, etc.) In order to meet the requirements of all
> geographies into which our adapters ship (over 100 countries) we have
> placed the regulatory enforcement logic into a user space daemon that
> we provide as a binary under the same license agreement as the
> microcode.  We provide that binary pre-compiled as both a 32-bit and

the regualatory problems are not true.  they are completely focused on
the users.  Someone who wants to change it can always do it, may it be
by binary patching.  I don't know of a single country that forbids
implementing those bits in source code shipped, and in those countries
we alredy couldn't distribute the kernel.

A binary daemon is completely unacceptable and unless you fix that there
is zero chance the driver could get into mainline.  I'd also like to
urge the distributors to not put this crap in to weaken our free drivers
future.  Intel, please stop this madness and play by the rules.
