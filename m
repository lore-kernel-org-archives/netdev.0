From: Matt Mackall <mpm@selenic.com>
Subject: Re: PATCH: netpoll with xircom_cb
Date: Thu, 14 Oct 2004 15:54:40 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041014205440.GY5414@waste.org>
References: <qww8yaarph5.fsf@decibel.fi.muni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Petr Konecny <pekon@fi.muni.cz>
Content-Disposition: inline
In-Reply-To: <qww8yaarph5.fsf@decibel.fi.muni.cz>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Oct 14, 2004 at 04:41:10AM +0200, Petr Konecny wrote:
> Hi,
> 
> I have a headless computer with xircom pcmcia card and needed netconsole
> on it. After looking around in other drivers I concocted this patch.  It
> survived light testing. I have no documentation for the hw, so it maybe
> totally bogus. What do you think ?

Looks good to me.

In general, this generic approach is fine. We can sometimes avoid the
heavyweight IRQ manipulation by using internal driver locking, but
this is generally not a performance-critical path. 

Jeff, did you take this one?

-- 
Mathematics is the supreme nostalgia of our time.
