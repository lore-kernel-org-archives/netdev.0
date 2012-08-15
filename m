From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [REVIEW][PATCH 0/21] User namespace changes to the networking
	stack.
Date: Tue, 14 Aug 2012 17:12:03 -0700 (PDT)
Message-ID: <20120814.171203.1784557890475348401.davem@davemloft.net>
References: <87ehnav9n5.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87ehnav9n5.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Date: Mon, 13 Aug 2012 13:07:10 -0700

> 
> This is a modest set of changes against the current networking stack to
> enable basic user namespace support.  Allowing the code to compile with
> user namespaces enabled and removing the assumption that there is only
> the initial user namespace.
> 
> Work to relax the privilege checks in the networking stack from
> "capable(CAP_NET_ADMIN)" or "capable(CAP_NET_RAW)" to
> "ns_capable(net->user_ns, CAP_NET_ADMIN)" or 
> "ns_capable(net->user_ns, CAP_NET_RAW)" allowing root in a user
> namespace to control a network namespace will come later.
> 
> David there are just enough interdependencies between the user namespace
> bits that I intend to merge them all through my user namespace tree.
> After the review is complete I will add these patches to my for-next
> branch of my user-namespace.git tree where I do not intend to rebase.
> If it make sense to pull these into net-next to avoid or reduce
> conflicts that should not be a problem.

Looks fine to me, you can add:

Acked-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

to all of this stuff.  Let me know when something is stable in your
tree, and I can therefore pull from it into net-next.
