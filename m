From: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Subject: Re: [PATCH v2 0/5] cgroup cls & netprio 'cleanups'
Date: Fri, 13 Jul 2012 15:53:37 +0200
Message-ID: <50002861.4070205@monom.org>
References: <1341999341-1808-1-git-send-email-wagi@monom.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1341999341-1808-1-git-send-email-wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 11.07.2012 11:35, Daniel Wagner wrote:
> The next two patches are changing the built. In case someone
> builds a kernel with cgroup support but disabled cls or netprio
> controller, there was still code added.
>
> And the last two patches change the cls and netprio source files in
> that way, that the use IS_BUILTIN and IS_MODULE as it used in the
> header files.

Forget patch #2 - #5.

I'll have a new version soon ready which changes the *_subsys_id part to 
always beeing a enum. This allows to remove the rather unpleasant module 
loading part with the ID assignment.

cheers,
daniel
