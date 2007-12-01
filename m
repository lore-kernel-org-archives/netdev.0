From: Stephen Hemminger <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: namespace support requires network modules to say "GPL"
Date: Sat, 1 Dec 2007 11:38:15 -0800
Message-ID: <20071201113815.5df0960a@freepuppy.rosehill>
References: <m163zi9425.fsf@ebiederm.dsl.xmission.com>
	<47515D39.9030900@rtr.ca>
	<20071201111736.297dd99a@freepuppy.rosehill>
	<20071201192341.6750fbdb@the-village.bc.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, kay.sievers-tD+1rO4QERM@public.gmane.org,
        Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cornelia.huck-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org,
        stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>,
        Mark Lord <lkml-gsilrlXbHYg@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
        Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
To: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071201192341.6750fbdb-v58gJUvfdfWUJIigds3554dd74u8MsAO@public.gmane.org>
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

On Sat, 1 Dec 2007 19:23:41 +0000
Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org> wrote:

> > Then init_net needs to be not GPL limited. Sorry, we need to allow
> > non GPL network drivers.  There is a fine line between keeping the
> 
> Why - they aren't exactly likely to be permissible by law

Matter of debate in which there are several opinions.
I don't like binary modules either, but don't feel qualified to render
a legal opinion.

> 
> > binary seething masses from accessing random kernel functions, and allowing
> > reasonable (but still non GPL) things like ndiswrapper to use network
> > device interface.
> 
> Its up to the ndiswrapper authors how the licence their code, but they
> should respect how we licence ours.

Then change the license, explicitly and get it approved, forcing license
changes by technically subversive means is bad policy. It is like Euro bureaucrats
sneaking in software patents in regulations. If you want to have the debate and
can get it resolved, then I support you.

Actually, the whole mess would go away if the api for dev_get_by_XXXX hadn't
been changed in the namespace transition. IMHO the interface to dev_get_by_name()
should not have added a namespace parameter, of the callers in the tree, only
two use a different namespace. So it would have been better to to introduce
dev_get_by_name_ns() with the extra parameter.

Can we get this resolved before 2.6.24 is released? Going back and forth
on API's is just needless frottage.

-- 
Stephen Hemminger <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
