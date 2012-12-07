From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH RFC 0/5] Containerize syslog
Date: Fri, 07 Dec 2012 10:05:59 -0800
Message-ID: <87r4n1buuw.fsf@xmission.com>
References: <50A9EAD8.9090501@gmail.com> <874nklkjjm.fsf@xmission.com>
	<20121207010355.c809b3f7.akpm@linux-foundation.org>
	<20121207142331.GC4004@sergelap> <50C1FD9D.5020703@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Rui Xiang <leo.ruixiang-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <50C1FD9D.5020703-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> (Glauber Costa's message of
	"Fri, 7 Dec 2012 18:30:53 +0400")
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

Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> writes:

> I keep asking myself if it isn't the case of forwarding to a container
> all messages printed in process context. That will obviously exclude all
> messages resulting from kthreads - that will always be in the initial
> namespace anyway, interrupts, etc. There is no harm, for instance, in
> delivering the same message twice: one to the container, and the other
> to the host system.

Except that there is harm in double printing.  One of the better
justifications for doing something with the kernel log is that it is
possible to overflow the kernel log with operations performed
exclusively in a container.

I do think the idea of process context printks going to the current
container one worth playing with.

Eric
