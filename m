From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 1/2] can: bfin_can: simplify xmit
	id1 setup
Date: Mon, 27 Jun 2011 20:42:44 -0700 (PDT)
Message-ID: <20110627.204244.61181347584724143.davem@davemloft.net>
References: <1308925982-14645-1-git-send-email-vapier@gentoo.org>
	<20110627074355.GA318@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vapier-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org,
        wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org, uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
To: kurt.van.dijck-/BeEPy95v10@public.gmane.org
Return-path: <uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org>
In-Reply-To: <20110627074355.GA318-MxZ6Iy/zr/UdbCeoMzGj59i2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://blackfin.uclinux.org/mailman/options/uclinux-dist-devel>,
	<mailto:uclinux-dist-devel-request-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org?subject=unsubscribe>
List-Archive: <http://blackfin.uclinux.org/pipermail/uclinux-dist-devel>
List-Post: <mailto:uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org>
List-Help: <mailto:uclinux-dist-devel-request-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org?subject=help>
List-Subscribe: <https://blackfin.uclinux.org/mailman/listinfo/uclinux-dist-devel>,
	<mailto:uclinux-dist-devel-request-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org?subject=subscribe>
Sender: uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
Errors-To: uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Date: Mon, 27 Jun 2011 09:43:55 +0200

> On Fri, Jun 24, 2011 at 10:33:01AM -0400, Mike Frysinger wrote:
>> If we look closely, the 4 writes to TRANSMIT_CHL.id1 can be collapsed
>> down into much simpler code.  So do just that.
>> 
>> This also fixes a build failure due to the I/O macros no longer
>> getting pulled in.  Their minor (and accidental) usage here gets
>> dropped as part of the unification.
>> 
>> Signed-off-by: Mike Frysinger <vapier-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
> 
> Nice cleanup.
> Acked-by: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>

Applied.
