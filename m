From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.24 regression: reference count leak in PPPoE
Date: Sun, 20 Jan 2008 16:07:58 -0800 (PST)
Message-ID: <20080120.160758.160048986.davem@davemloft.net>
References: <200801202053.30386.ak@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ak@suse.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756679AbYAUAII@vger.kernel.org>
In-Reply-To: <200801202053.30386.ak@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@suse.de>
Date: Sun, 20 Jan 2008 20:53:30 +0100

> 
> My workstation running 2.6.24-rc8 just hung during shutdown with an endless 
> (or rather I didn't wait more than a few minutes) loop of 
> 
> unregister_netdev: waiting for ppp-device to become free. Usage count = 1
> 
> ppp-device was an active PPPoE device.
> 
> No more information currently.

http://bugzilla.kernel.org/show_bug.cgi?id=9778
