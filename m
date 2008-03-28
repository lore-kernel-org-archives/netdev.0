From: "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 3/11 net-2.6.26] [DCCP]: dccp_v(4|6)_ctl_socket is leaked.
Date: Fri, 28 Mar 2008 20:09:51 +0300
Message-ID: <1206724191.8599.0.camel@iris.sw.ru>
References: <1206695071.3271.8.camel@iris.sw.ru>
	<1206695338-5947-3-git-send-email-den@openvz.org>
	<20080328144446.GU14945@ghostprotocols.net>
	<1206717778.4294.4.camel@iris.sw.ru>
	<20080328164752.GX14945@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080328164752.GX14945-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>
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

On Fri, 2008-03-28 at 13:47 -0300, Arnaldo Carvalho de Melo wrote:
> Em Fri, Mar 28, 2008 at 06:22:58PM +0300, Denis V. Lunev escreveu:
> > On Fri, 2008-03-28 at 11:44 -0300, Arnaldo Carvalho de Melo wrote:
> > > Em Fri, Mar 28, 2008 at 12:08:50PM +0300, Denis V. Lunev escreveu:
> > > > This seems a purism as module can't be unloaded, but though if cleanup method
> > > > is present it should be correct and clean all staff created.
> > > 
> > > Its the right thing to do :-) But perhaps we could have a
> > > inet_csk_ctl_sock_destroy() as we have inet_csk_ctl_sock_create?
> > > 
> > > And since this is not csk at all, could you please rename it to
> > > inet_ctl_sock_{create,destroy}()? I Agree with Vlad and Pavel that this
> > > would make it more clear, as SCTP is not (yet) a inet_connection_sock.
> > 
> > Basically, after these sockets will be moved into namespace we'll use
> > sk_release_kernel for them.
> > 
> > Can I send a rename as a follow up on Monday :) ?
> 
> Logically the rename should be done first, then its use, but its up to
> Dave/you.

seems logical. OK, I'll redo this.
