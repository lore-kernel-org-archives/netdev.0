From: Bruno Randolf <bruno-L9ZBdB2wSWtl57MIdRCFDg@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2008-08-26
Date: Thu, 28 Aug 2008 12:35:34 +0200
Message-ID: <200808281235.35449.bruno@thinktube.com>
References: <20080827013009.GA15781@tuxdriver.com> <1ba2fa240808271611v382631ecn2a24e2816562d434@mail.gmail.com> <20080827233103.GE5927@tesla>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Luis R. Rodriguez" <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Tomas Winkler <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080827233103.GE5927@tesla>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 27, 2008 at 04:11:15PM -0700, Tomas Winkler wrote:
> Last solution would be to remove this merging all together but then
> I'm not sure if Bruno added this code just implement the spec or
> really tested it with any hardware.

of course i tested IBSS merge with atheros hardware when i sent in the patch 
and it worked. this is about 6 month ago. recently i briefly tested IBSS, 
with the same HW but it did not work any more - i didn't have the time to 
investigate this issue...

please remember that there was a lengthy discussion about the standard 
compliance and the reasons behind the need for IBSS merge before my patch was 
accepted. i believe i had convincing arguments why IBSS mode does not 
reliably work at all in practice if we don't support IBSS merge.

you might want to re-read this thread:
http://thread.gmane.org/gmane.linux.kernel.wireless.general/10278

greetings,
bruno
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
