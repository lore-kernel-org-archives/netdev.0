From: "Andrew Grover" <andy.grover@gmail.com>
Subject: Re: [PATCH 1/9] [I/OAT] DMA memcpy subsystem
Date: Thu, 30 Mar 2006 10:36:29 -0800
Message-ID: <c0a09e5c0603301036s4e9a63e5v476d89ff8ba37760@mail.gmail.com>
References: <20060329225505.25585.30392.stgit@gitlost.site>
	 <20060329225548.25585.73037.stgit@gitlost.site>
	 <8C52750C-8BC3-4815-834C-6DBEA714BA0F@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Chris Leech" <christopher.leech@intel.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750726AbWC3Sgb@vger.kernel.org>
To: "Kumar Gala" <galak@kernel.crashing.org>
In-Reply-To: <8C52750C-8BC3-4815-834C-6DBEA714BA0F@kernel.crashing.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/30/06, Kumar Gala <galak@kernel.crashing.org> wrote:
> What is the utility of exporting memcpy_count, and bytes_transferred
> to userspace via sysfs?  Is this really for debug (and thus should be
> under debugfs?)

Well....it's true they're useful for debugging but I would put them in
the category of system statistics that shouldn't go in debugfs. I
think they are like /proc/interrupts' interrupt counts or the TX/RX
stats reported by ifconfig.

Regards -- Andy
