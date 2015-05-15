From: Paul Moore <pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH V6 05/10] audit: log creation and deletion of namespace instances
Date: Fri, 15 May 2015 16:42:38 -0400
Message-ID: <2697338.ReFgH43Z0x@sifl>
References: <cover.1429252659.git.rgb@redhat.com> <20150515004855.GB10526@madcap2.tricolour.ca> <CAA4jN2bgynVTwF+owtXgq06JMLQJpy_qokpD0mAguNYeDxmh1A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Steve Grubb <sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org, zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org,
	Eric Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
To: Oren Laadan <orenl-3AfRa/s5aFdBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAA4jN2bgynVTwF+owtXgq06JMLQJpy_qokpD0mAguNYeDxmh1A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thursday, May 14, 2015 09:10:56 PM Oren Laadan wrote:
> [focusing on "containers id" - snipped the rest away]
> 
> I am unfamiliar with the audit subsystem, but work with namespaces in other
> contexts. Perhaps the term "container" is overloaded here. The definition
> suggested by Steve in this thread makes sense to me: "a combination of
> namespaces". I imagine people may want to audit subsets of namespaces.
> 
> For namespaces, can use a string like "A:B:C:D:E:F" as an identifier for a
> particular combination, where A-F are respective namespaces identifiers.
> (Can be taken for example from /proc/PID/ns/{mnt,uts,ipc,user,pid,net}).
>  That will even be grep-able to locate records related to a particular
> subset
> of namespaces. So a "container" in the classic meaning would have all A-F
> unique and different from the init process, but processes separated only by
> e.g. mnt-ns and net-ns will differ from the init process in  A and F.
> 
> (If a string is a no go, then perhaps combine the IDs in a unique way into a
> super ID).

As has been mentioned in every other email in this thread, the kernel has no 
concept of a container, it is a userspace idea and trying to generate a 
meaningful value in the kernel is a mistake in my opinion.  My current opinion 
is that we allow userspace to set a container ID token as it sees fit and the 
kernel will just use the value provided by userspace.

-- 
paul moore
security @ redhat
