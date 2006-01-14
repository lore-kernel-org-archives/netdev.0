From: Dan Williams <dcbw@redhat.com>
Subject: Re: wireless: recap of current issues (configuration)
Date: Sat, 14 Jan 2006 18:41:56 -0500
Message-ID: <1137282117.27849.11.camel@localhost.localdomain>
References: <20060113195723.GB16166@tuxdriver.com>
	 <20060113212605.GD16166@tuxdriver.com>
	 <20060113213011.GE16166@tuxdriver.com>
	 <20060113221935.GJ16166@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751031AbWANXns@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060113221935.GJ16166@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-01-13 at 17:19 -0500, John W. Linville wrote:
> Configuration
> =============
> 
> Configuration seems to be coalescing around netlink.  Among other
> things, this technology provides for muliticast requests and
> asynchronous event notification.
> 
> The kernel should provide generic handlers for netlink
> configuraion messages, and there should be a per-device 80211_ops
> (wireless_ops? akin to ethtool_ops) structure for drivers to
> populate appropriately.

One other thing: capability.  It's not enough to be able to configure
the device, user-space tools also have to know what the device is
capable of before they try touching it.  Ie, which ciphers, protocols,
channels, etc.  Similar to the IWRANGE ioctl that there is now.  Half
the problem now is that you can't reliably tell what drivers support
which features, or how much they support a particular feature.  Think of
ethernet devices and whether or not they support carrier detection,
there's absolutely no way to tell that now (unless they respond to
ethtool or MII, and some cards freeze if you touch them with MII too
often).

Dan
