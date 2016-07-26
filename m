From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v2 02/10] userns: Add per user namespace sysctls.
Date: Mon, 25 Jul 2016 19:58:36 -0700 (PDT)
Message-ID: <20160725.195836.1881375122073635224.davem@davemloft.net>
References: <878twp6zd2.fsf@x220.int.ebiederm.org>
	<20160725.172406.352408511647766870.davem@davemloft.net>
	<87k2g95it9.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org,
	seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org, kernel-6AxghH7DbtA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org
To: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87k2g95it9.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
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

From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Date: Mon, 25 Jul 2016 19:44:50 -0500

> User namespaces have enabled unprivileged users access to a lot more
> data structures and so to catch programs that go crazy we need a lot
> more limits.  I believe some of those limits make sense per namespace.
> As it is easy in some cases to say any more than Y number of those
> per namespace is excessive.   For example a limit of 1,000,000 ipv4
> routes per network namespaces is a sanity check as there are
> currently 621,649 ipv4 prefixes advertized in bgp.

When we give a new namespace to unprivileged users, we honestly should
make the sysctl settings we give to them become "limits".  They can
further constrain the sysctl settings but may not raise them.
