From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 1/4] net: phy: call put_device on device_register()
 failure
Date: Sat, 14 Dec 2013 09:25:45 -0800
Message-ID: <20131214172545.GD22520@kroah.com>
References: <1386959996-7958-1-git-send-email-levex@linux.com>
 <1386959996-7958-2-git-send-email-levex@linux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>,
	Grant Likely <grant.likely@secretlab.ca>,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	netdev@vger.kernel.org
To: Levente Kurusa <levex@linux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1386959996-7958-2-git-send-email-levex@linux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 13, 2013 at 07:39:53PM +0100, Levente Kurusa wrote:
> It is required to call put_device() if device_register() fails,
> so that we give up the last reference to the device. Calling put_device
> allows for mdiobus_release to be executed, kfreeing the bus.
> 
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: Grant Likely <grant.likely@secretlab.ca>
> Signed-off-by: Levente Kurusa <levex@linux.com>

Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
