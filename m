From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH] 2.6 UDP recvmsg vs POSIX
Date: Tue, 24 Feb 2004 10:32:34 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040224093234.GB7886@suse.de>
References: <20040217121726.GD8554@suse.de> <20040221130853.4c98bad6.davem@redhat.com> <20040223094209.GA12663@suse.de> <20040223094216.66602afd.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040223094216.66602afd.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Feb 23, 2004 at 09:42:16AM -0800, David S. Miller wrote:
> Therefore, the only bug was returning -EAGAIN unconditionally and that's
> what is fixed by the correct half of your changes.
> 
> TCP does the same thing Olaf, and there is no way I'm adding the gross poll
> hacks there :-)

Okay, I can live with that. I will push this info to our posix
guys and let them chew on it.

UDPv6 needs the exact same fix BTW.

Cheers,
Olaf
-- 
Olaf Kirch     |  Stop wasting entropy - start using predictable
okir@suse.de   |  tempfile names today!
---------------+ 
