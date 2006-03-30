From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH 1/9] [I/OAT] DMA memcpy subsystem
Date: Thu, 30 Mar 2006 13:57:51 -0600
Message-ID: <351C5BDA-D7E3-4257-B07E-ABDDCF254954@kernel.crashing.org>
References: <20060329225505.25585.30392.stgit@gitlost.site> <20060329225548.25585.73037.stgit@gitlost.site> <8C52750C-8BC3-4815-834C-6DBEA714BA0F@kernel.crashing.org> <c0a09e5c0603301036s4e9a63e5v476d89ff8ba37760@mail.gmail.com>
Mime-Version: 1.0 (Apple Message framework v746.3)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Chris Leech" <christopher.leech@intel.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750791AbWC3T5m@vger.kernel.org>
In-Reply-To: <c0a09e5c0603301036s4e9a63e5v476d89ff8ba37760@mail.gmail.com>
To: Andrew Grover <andy.grover@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Mar 30, 2006, at 12:36 PM, Andrew Grover wrote:

> On 3/30/06, Kumar Gala <galak@kernel.crashing.org> wrote:
>> What is the utility of exporting memcpy_count, and bytes_transferred
>> to userspace via sysfs?  Is this really for debug (and thus should be
>> under debugfs?)
>
> Well....it's true they're useful for debugging but I would put them in
> the category of system statistics that shouldn't go in debugfs. I
> think they are like /proc/interrupts' interrupt counts or the TX/RX
> stats reported by ifconfig.

Fair, but wouldn't it be better to have the association per client.

Maybe leave the one as a summary and have a dir per client with  
similar stats that are for each client and add a per channel summary  
at the top level as well.

- kumar
