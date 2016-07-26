From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH v2 02/10] userns: Add per user namespace sysctls.
Date: Mon, 25 Jul 2016 19:44:50 -0500
Message-ID: <87k2g95it9.fsf@x220.int.ebiederm.org>
References: <20160721164014.17534-1-ebiederm@xmission.com>
	<20160721164014.17534-2-ebiederm@xmission.com>
	<878twp6zd2.fsf@x220.int.ebiederm.org>
	<20160725.172406.352408511647766870.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org,
	seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org, kernel-6AxghH7DbtA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20160725.172406.352408511647766870.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> (David
	Miller's message of "Mon, 25 Jul 2016 17:24:06 -0700 (PDT)")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> writes:

> From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
> Date: Mon, 25 Jul 2016 19:02:01 -0500
>
>>            Which means this change gets has to wait for next cycle.
>
> Ok.

For clarity I intend to merge these changes through the userns tree,
when the issues are resolved.

I Cc'd netdev as there is a limit on the number of network namespaces in
this set which may be of interest to networking folks.

I expect there will be some follow on about adding sanity checking
limits to other kernel data structures like a maximum number of mounts
in a mount namespace, and perhaps a maximum number of routes in a
network namespace.

User namespaces have enabled unprivileged users access to a lot more
data structures and so to catch programs that go crazy we need a lot
more limits.  I believe some of those limits make sense per namespace.
As it is easy in some cases to say any more than Y number of those
per namespace is excessive.   For example a limit of 1,000,000 ipv4
routes per network namespaces is a sanity check as there are
currently 621,649 ipv4 prefixes advertized in bgp.

But that is something to worry about after the merge window.

Eric
