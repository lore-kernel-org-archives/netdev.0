From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] net: net_cls: fd passed in SCM_RIGHTS datagram not set
 correctly
Date: Mon, 21 Jan 2013 14:17:52 -0500 (EST)
Message-ID: <20130121.141752.1744701325219813159.davem@davemloft.net>
References: <1358761102-7765-1-git-send-email-wagi@monom.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org,
	john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
To: wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1358761102-7765-1-git-send-email-wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Date: Mon, 21 Jan 2013 10:38:22 +0100

> From: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
> 
> Commit 6a328d8c6f03501657ad580f6f98bf9a42583ff7 changed the update
> logic for the socket but it does not update the SCM_RIGHTS update
> as well. This patch is based on the net_prio fix commit
> 
> 48a87cc26c13b68f6cce4e9d769fcb17a6b3e4b8
> 
>     net: netprio: fd passed in SCM_RIGHTS datagram not set correctly
> 
>     A socket fd passed in a SCM_RIGHTS datagram was not getting
>     updated with the new tasks cgrp prioidx. This leaves IO on
>     the socket tagged with the old tasks priority.
> 
>     To fix this add a check in the scm recvmsg path to update the
>     sock cgrp prioidx with the new tasks value.
> 
> Let's apply the same fix for net_cls.
> 
> Reported-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>

You need to resubmit this, and proprly add a "Signed-off-by: " tag
for yourself.
