From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH V10 01/15] time: Introduce timekeeping_inject_offset
Date: Fri, 28 Jan 2011 08:08:00 +0100
Message-ID: <20110128070800.GA3225@riccoc20.at.omicron.at>
References: <cover.1296124770.git.richard.cochran@omicron.at>
 <6aec014551fc1d34924d6a7bcf97769867c15ba9.1296124770.git.richard.cochran@omicron.at>
 <1296154099.2855.162.camel@work-vm>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Richard Cochran <richard.cochran-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
	Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Mike Frysinger <vapier-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>,
	Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>,
	Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
To: John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1296154099.2855.162.camel@work-vm>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 27, 2011 at 10:48:19AM -0800, John Stultz wrote:
> While I appreciate you preserving the path author, and the signoffs are
> right, you really should send the email under your own name.

Guess I've been reading too much spam. It wore off on me.
 
> The proper style is to keep the mail-header From: the same (ie: Richard
> Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>), but as the first line of the mail
> body put:
>    From: Author Name <author-MBgCfJrXA/zQT0dZR+AlfA@public.gmane.org>

Sorry about this. Arnd already explained this to me, and I did catch
it with V9. This time I forgot.

I would like to get to the bottom of this. Here is what I did:

   1. Saved your patch to disk in mbox format using Mutt.
   2. git am
   3. ... rebase, rebase, rebase, ...
   4. git format-patch [options] 1234..abcd
   5. Edit cover letter
   6. for x in 00*; do mutt -H $x; done

Git format-patch places the "From: John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>"
line with the other mail headers, and so I guess mutt just faithfully
preserves this.

I don't like having to remember to fix this manually. There must be a
better way...

Sorry,
Richard
