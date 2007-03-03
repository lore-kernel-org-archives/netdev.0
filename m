From: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] schedule wext/rtnl for removal
Date: Fri, 02 Mar 2007 20:25:01 -0500
Message-ID: <45E8CE6D.6000801@garzik.org>
References: <20070301153105.GC5806@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070301153105.GC5806-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
> 
> Since wext is being replaced as fast as we can (it'll probably stick
> around for legacy drivers though) and the wext/netlink stuff was never
> really used, this schedules it for removal.
> 
> The removal schedule is tight but there are no users of the code, the
> main user of the wext user interface are the wireless-tools, they only
> have an alpha version using the netlink interface and even that is
> incomplete.
> 
> Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
> Signed-off-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> ---
> Which you consider applying this feature-removal-schedule.txt patch
> in the current (i.e. pre-2.6.21) timeframe?
> 
>  Documentation/feature-removal-schedule.txt |   12 ++++++++++++
>  1 file changed, 12 insertions(+)

When you send this sort of stuff, spam as many lists as reasonable.

The removal of a recently-added userspace ABI is an unusual event, and 
IMO needs discussing.
