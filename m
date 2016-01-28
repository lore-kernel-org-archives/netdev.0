From: Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/3] param: convert some "on"/"off" users to strtobool
Date: Thu, 28 Jan 2016 16:27:51 +0100
Message-ID: <20160128152751.GB3926@osiris>
References: <1453990627-19164-1-git-send-email-keescook@chromium.org>
 <1453990627-19164-4-git-send-email-keescook@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>,
	Rasmus Villemoes <linux-qQsb+v5E8BnlAoU/VqSP6n9LOBIZ5rWg@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	Amitkumar Karwar <akarwar-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
	Nishant Sarmukadam <nishants-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Steve French <sfrench-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>,
	Michael Ellerman <mpe-Gsx/Oe8HsFggBc27wqDAHg@public.gmane.org>,
	Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Return-path: <linux-cifs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1453990627-19164-4-git-send-email-keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Sender: linux-cifs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 28, 2016 at 06:17:07AM -0800, Kees Cook wrote:
> This changes several users of manual "on"/"off" parsing to use strtobool.
> 
> Signed-off-by: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
> Cc: x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
> Cc: linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
> Cc: linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> ---
>  arch/powerpc/kernel/rtasd.c                  | 10 +++-------
>  arch/powerpc/platforms/pseries/hotplug-cpu.c | 11 +++--------
>  arch/s390/kernel/time.c                      |  8 ++------
>  arch/s390/kernel/topology.c                  |  8 +++-----
>  arch/x86/kernel/aperture_64.c                | 13 +++----------
>  include/linux/tick.h                         |  2 +-
>  kernel/time/hrtimer.c                        | 11 +++--------
>  kernel/time/tick-sched.c                     | 11 +++--------
>  8 files changed, 21 insertions(+), 53 deletions(-)

For the s390 bits:

Acked-by: Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
