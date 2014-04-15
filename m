From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [PATCH 1/2] net: Implement SO_PEERCGROUP
Date: Tue, 15 Apr 2014 14:54:02 -0700
Message-ID: <CALCETrV7ZwWtCJQ2uF3WmctTj0qBkh2MRQS4uy9vPhP0zKPYrQ@mail.gmail.com>
References: <1397596546-10153-1-git-send-email-vgoyal@redhat.com> <1397596546-10153-2-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Simo Sorce <ssorce-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	kay-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1397596546-10153-2-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 15, 2014 at 2:15 PM, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> Implement SO_PEERCGROUP along the lines of SO_PEERCRED. This returns the
> cgroup of first mounted hierarchy of the task. For the case of client,
> it represents the cgroup of client at the time of opening the connection.
> After that client cgroup might change.
>
> This works only for unix stream sockets.

I still don't understand why this is useful when SCM_CGROUP exists.

--Andy
