From: John Dykstra <john.dykstra1-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 2/2] c/r: Add AF_INET support (v3)
Date: Wed, 29 Jul 2009 17:10:29 -0500
Message-ID: <1248905429.7129.22.camel@Maple>
References: <1246994776-1882-1-git-send-email-danms@us.ibm.com>
	<1246994776-1882-3-git-send-email-danms@us.ibm.com>
	<1248555754.16746.55.camel@merlyn>
	<874oswer21.fsf@caffeine.danplanet.com>
	<4A6F306A.40303@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A6F306A.40303-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2009-07-28 at 13:07 -0400, Oren Laadan wrote:
> When you destroy the virtual interface after (or during) the
> > migration, the TIME_WAIT socket will disappear from the sending
> host.
> 
> Note that such sockets are unlikely to be referenced by _any_ process
> because they will have been closed already. So the checkpoint code
> will need to find such sockets not through file descriptors.

Dan, to maybe save you some searching...  The time-wait chains can be
accessed via tcp_hashinfo.

  -- John
