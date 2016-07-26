From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH v2 02/10] userns: Add per user namespace sysctls.
Date: Mon, 25 Jul 2016 23:00:31 -0500
Message-ID: <877fc92gm8.fsf@x220.int.ebiederm.org>
References: <878twp6zd2.fsf@x220.int.ebiederm.org>
	<20160725.172406.352408511647766870.davem@davemloft.net>
	<87k2g95it9.fsf@x220.int.ebiederm.org>
	<20160725.195836.1881375122073635224.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org, seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org, kernel-6AxghH7DbtA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160725.195836.1881375122073635224.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> (David
	Miller's message of "Mon, 25 Jul 2016 19:58:36 -0700 (PDT)")
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> writes:

> From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
> Date: Mon, 25 Jul 2016 19:44:50 -0500
>
>> User namespaces have enabled unprivileged users access to a lot more
>> data structures and so to catch programs that go crazy we need a lot
>> more limits.  I believe some of those limits make sense per namespace.
>> As it is easy in some cases to say any more than Y number of those
>> per namespace is excessive.   For example a limit of 1,000,000 ipv4
>> routes per network namespaces is a sanity check as there are
>> currently 621,649 ipv4 prefixes advertized in bgp.
>
> When we give a new namespace to unprivileged users, we honestly should
> make the sysctl settings we give to them become "limits".  They can
> further constrain the sysctl settings but may not raise them.

I won't disagree.  I was thinking in terms of global setting that
hold the limits for per namespace counters.  As we are talking sanity
check limits.

Perhaps we could get sophisticated and do something more but the simpler
we can make things and get the job done the better.

Eric
