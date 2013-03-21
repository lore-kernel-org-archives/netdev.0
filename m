From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH RFC 1/5] kconfig: implement weak reverse-dependencies
Date: Thu, 21 Mar 2013 12:43:08 +0100
Message-ID: <20130321114307.GA6716@netboy.at.omicron.at>
References: <20130321082256.21557.68351.stgit@zurg>
 <20130321102200.GB2341@netboy.at.omicron.at>
 <514AE9A3.5090209@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michal Marek <mmarek@suse.cz>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-kbuild@vger.kernel.org,
	Tejun Heo <tj@kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <514AE9A3.5090209@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 21, 2013 at 03:06:11PM +0400, Konstantin Khlebnikov wrote:
> 
> As I see this technology requires special dedicated server in the local
> network, thus it's unusable in most situations. But it starts working
> without any actions from the user (please fix me if I'm wrong).

Perhaps you don't have a very clear picture of how this PTP stuff
works. Even when the PHC and time stamping code is compiled in, it
does *not* start working unless the end user turns it on, via the
SIOCSHWTSTAMP and SO_TIMESTAMPING options.

See: Documentation/networking/timestamping.txt
     Documentation/ptp/ptp.txt
 
> Thus this code enables some rarely used parts of hardware.
> After seeing several weird bugs in ethernet devices I prefer to
> keep unused/unwanted features off.

Just compiling drivers into kernel does not really change the behavior
of the hardware. The only drawback I know of is that it adds (minimal)
overhead into the packet processing paths, but that is a software
issue.

I don't mean to start a big discussion here. The question of whether
to have PHC support a compile time option should be discussed on the
netdev list (added on CC just in case).

Thanks,
Richard
