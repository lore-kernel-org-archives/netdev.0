From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: sunrpc port allocation and IANA reserved list
Date: Tue, 10 Nov 2009 17:53:43 +0000
Message-ID: <1257875623.2834.19.camel@achroite.uk.solarflarecom.com>
References: <4AF9A63B.6010101@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Linux kernel <linux-kernel@vger.kernel.org>
To: Chris Friesen <cfriesen@nortel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752232AbZKJRxm@vger.kernel.org>
In-Reply-To: <4AF9A63B.6010101@nortel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2009-11-10 at 11:43 -0600, Chris Friesen wrote:
> By default sunrpc ports are allocated at random in the range 665-1023U.
>  However, there are many ports within this range which have been
> reserved by the IANA (and others like port 921 which are not formally
> reserved but are "well-known").
> 
> Given that a userspace application can be stopped and restarted at any
> time, and a sunrpc registration can happen at any time, what is the
> expected mechanism to prevent the kernel from allocating a port for use
> by sunrpc that reserved or well-known?
> 
> Apparently Redhat and Debian have distro-specific ways of dealing with
> this, but is there a standard solution?  Should there be?
> 
> The current setup seems suboptimal.

I believe both RH and Debian are using the same implementation:
<http://cyberelk.net/tim/software/portreserve/>.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
