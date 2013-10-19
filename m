From: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH nf-next] netfilter: xtables: lightweight process control
 group matching
Date: Sat, 19 Oct 2013 09:16:48 +0200
Message-ID: <526231E0.6060903@redhat.com>
References: <1380910855-12325-1-git-send-email-dborkman@redhat.com> <87li1qp3l8.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87li1qp3l8.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 10/19/2013 01:21 AM, Eric W. Biederman wrote:

> I am coming to this late.  But two concrete suggestions.
>
> 1) process groups and sessions don't change as frequently as pids.
>
> 2) It is possible to put a set of processes in their own network
>     namespace and pipe just the packets you want those processes to
>     use into that network namespace.  Using an ingress queueing filter
>     makes that process very efficient even if you have to filter by port.

Actually in our case we're filtering outgoing traffic, based on which
local socket that originated from; so you wouldn't need all of that
construct. Also, you wouldn't even need to have an a-prio knowledge of
the application internals regarding their use of particular use of ports
or protocols. I don't think that such a setup will have the same
efficiency, ease of use, and power to distinguish the application the
traffic came from in such a lightweight, protocol independent and easy way.
