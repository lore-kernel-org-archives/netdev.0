From: Evgeniy Polyakov <zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org>
Subject: Re: [RFC v2 1/2] proc connector: add namespace events
Date: Thu, 20 Oct 2016 20:12:03 +0300
Message-ID: <84641476983523@web30m.yandex.ru>
References: <1476534370-4027-1-git-send-email-alban@kinvolk.io>
	<1476534370-4027-2-git-send-email-alban@kinvolk.io>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Iago Lopez Galeiras <iago-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>, Aaron Campbell <aaron-J6AcJDG0ZEwdnm+yROfE0A@public.gmane.org>,
	Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Jesper Derehag <jderehag-PkbjNfxxIARBDgjK7y7TUQ@public.gmane.org>,
	Alban Crequy <alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Dimitri John Ledkov <dimitri.j.ledkov-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Alban Crequy <alban.crequy-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org"
	<containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1476534370-4027-2-git-send-email-alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>
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

Hi Alban

15.10.2016, 15:28, "Alban Crequy" <alban.crequy-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>:
> + /* net */
> + if (prepare->net_inum != ns->net_ns->ns.inum) {
> + ev->event_data.ns.items[count].type = CLONE_NEWNET;
> + ev->event_data.ns.items[count].flags = 0;
> + ev->event_data.ns.items[count].old_inum = prepare->net_inum;
> + ev->event_data.ns.items[count].inum = ns->net_ns->ns.inum;
> + count++;
> + }
> +
> + /* cgroup */
> + if (prepare->cgroup_inum != ns->cgroup_ns->ns.inum) {
> + ev->event_data.ns.items[count].type = CLONE_NEWNET;

NEWNET here looks like a type, isn't it?
