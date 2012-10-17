From: Boaz Harrosh <bharrosh-C4P08NqkoRlBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH] SUNRPC: Prevent kernel stack corruption on long values
 of flush
Date: Wed, 17 Oct 2012 11:29:44 -0700
Message-ID: <507EF918.5030004@panasas.com>
References: <1342476086-21638-1-git-send-email-levinsasha928@gmail.com> <20120718173913.GA1298@fieldses.org> <20120718200049.GA17964@umich.edu> <20120718203304.GA18540@redhat.com> <20120718205510.GA18374@umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	<Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jim Rees <rees-63aXycvo3TyHXe+LvDLADg@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120718205510.GA18374-63aXycvo3TyHXe+LvDLADg@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 07/18/2012 01:55 PM, Jim Rees wrote:
> Dave Jones wrote:
> 
>   
>   Unsigned long isn't necessarily 32 bits.
>   On 64-bit systems %lu can be up to 18446744073709551615
> 
> Thanks.  You caught me thinking "Intel."  How embarrassing.

What? why even on Intel-64 long is 64bit. long is always the
same or bigger then a pointer (A pointer must always fit
in a long)

On the other hand int is 32bit in Intel-64 unlike some
other CPUs where int(s) may get to be 64bit as well.

Cheers
Boaz
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
