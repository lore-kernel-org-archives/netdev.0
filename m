From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 1/3] sky2: tx pause bug fix
Date: Fri, 22 Sep 2006 10:27:24 -0700
Message-ID: <20060922102724.777bddb5@localhost.localdomain>
References: <08f701c6de22$b25420b0$0b00000a@bluereef.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:36585 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S964794AbWIVR11 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2006 13:27:27 -0400
To: "Andrew Hall" <andrew.hall@bluereefnetworks.com>
In-Reply-To: <08f701c6de22$b25420b0$0b00000a@bluereef.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 22 Sep 2006 18:40:00 +1000
"Andrew Hall" <andrew.hall@bluereefnetworks.com> wrote:

> >
> > If there's anything I can do to help isolate this issue please let me 
> > know.
> >
> 
> Looking through the logs I'm also intermittently seeing some of this:
> 
> sky2 eth1: rx error, status 0x7ffc0001 length 844

That means the driver is getting receive fifo overflows. You must
not be using receive flow control.

The driver takes no special action when this occurs. It isn't clear (even from
the documentation), what is supposed to be done.

-- 
Stephen Hemminger <shemminger@osdl.org>
