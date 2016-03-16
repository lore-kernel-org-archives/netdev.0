From: Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC PATCH kernel] Revert "net/mlx4_core: Set UAR page size to
 4KB regardless of system page size"
Date: Wed, 16 Mar 2016 11:45:42 +0200
Message-ID: <CAJ3xEMgorN4r-Ls66rc3VwUBi=uhb==ih2=43ujrbPC=ts8E5g@mail.gmail.com>
References: <1458037148-4475-1-git-send-email-aik@ozlabs.ru>
	<CAJ3xEMhxUuQj+E00fa-tEKz+dVzDqFspC80Z=k7UPZpOP30H3g@mail.gmail.com>
	<56E8BFFE.9000803@ozlabs.ru>
	<20160316051021.GC66645@x-vnc01.mtx.labs.mlnx>
	<56E8F3CC.3070203@ozlabs.ru>
	<20160316060947.GD66645@x-vnc01.mtx.labs.mlnx>
	<56E91A78.5000700@ozlabs.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, Huy Nguyen <huyn-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Eugenia Emantayev <eugenia-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Yishai Hadas <yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Linux Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>,
	Carol L Soto <clsoto-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Brian J King <bjking1-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
To: Alexey Kardashevskiy <aik-sLpHqDYs0B2HXe+LvDLADg@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <56E91A78.5000700-sLpHqDYs0B2HXe+LvDLADg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 16, 2016 at 10:34 AM, Alexey Kardashevskiy <aik-sLpHqDYs0B2HXe+LvDLADg@public.gmane.org> wrote:

> Oh. ok. It also looks like even with the reverted patch, mlx4 VF does not
> work in a guest:

So where is the breakage point for you? does 4.4 works? if not, what?
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
