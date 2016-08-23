From: Parav Pandit <pandit.parav-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 0/5] Networking cgroup controller
Date: Tue, 23 Aug 2016 13:07:43 +0530
Message-ID: <CAG53R5U_=c-7Uog78_1MJBuUXivopyqq8+Un9BgYTO4P3ytWRA@mail.gmail.com>
References: <1470876798-4024-1-git-send-email-anaravaram@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>,
        davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org, jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org,
        yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
        linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, maheshb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
        weiwan-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org
To: Anoop Naravaram <anaravaram-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1470876798-4024-1-git-send-email-anaravaram-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Anoop,


On Thu, Aug 11, 2016 at 6:23 AM, Anoop Naravaram <anaravaram-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
> This patchset introduces a cgroup controller for the networking subsystem as a
> whole. As of now, this controller will be used for:
>
> * Limiting the specific ports that a process in a cgroup is allowed to bind
>   to or listen on. For example, you can say that all the processes in a
>   cgroup can only bind to ports 1000-2000, and listen on ports 1000-1100, which
>   guarantees that the remaining ports will be available for other processes.
>
> * Restricting which DSCP values processes can use with their sockets. For
>   example, you can say that all the processes in a cgroup can only send
>   packets with a DSCP tag between 48 and 63 (corresponding to TOS values of
>   192 to 255).
>
> * Limiting the total number of udp ports that can be used by a process in a
>   cgroup. For example, you can say that all the processes in one cgroup are
>   allowed to use a total of up to 100 udp ports. Since the total number of udp
>   ports that can be used by all processes is limited, this is useful for
>   rationing out the ports to different process groups.
>
> In the future, more networking-related properties may be added to this
> controller.
>

Since network namespace allows process in each namespace to listen to
same port range in their own namespace.
What is the rationale or use case to limit certain process to view
certain port range?
