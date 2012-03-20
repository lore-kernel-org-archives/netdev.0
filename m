From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH wireless-next 2/3] ath5k: Introduce
 _ath5k_printk to reduce code/text
Date: Mon, 19 Mar 2012 20:48:01 -0700
Message-ID: <1332215281.7847.54.camel@joe2Laptop>
References: <cover.1332116921.git.joe@perches.com>
	<b157e2d1a746733d1814b9726f326d52d36da2fc.1332116921.git.joe@perches.com>
	<CAJ-Vmo=ceSV38vQGfs8cKJScWjYF4kbQdK3+JJvQLCmnURaEwA@mail.gmail.com>
	<1332134336.23125.60.camel@joe2Laptop>
	<CAJ-Vmom4n7Sk5P=HMb+Z-FNyfyk87Xbf5Q1kPA4i2eXwQ72kXQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, ath5k-devel-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Adrian Chadd <adrian-h+KGxgPPiopAfugRpC6u6w@public.gmane.org>
Return-path: <ath5k-devel-bounces-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org>
In-Reply-To: <CAJ-Vmom4n7Sk5P=HMb+Z-FNyfyk87Xbf5Q1kPA4i2eXwQ72kXQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.ath5k.org/mailman/listinfo/ath5k-devel>,
	<mailto:ath5k-devel-request-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ath5k.org/pipermail/ath5k-devel>
List-Post: <mailto:ath5k-devel-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org>
List-Help: <mailto:ath5k-devel-request-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ath5k.org/mailman/listinfo/ath5k-devel>,
	<mailto:ath5k-devel-request-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org?subject=subscribe>
Sender: ath5k-devel-bounces-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org
Errors-To: ath5k-devel-bounces-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-03-19 at 20:39 -0700, Adrian Chadd wrote:
> On 18 March 2012 22:18, Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org> wrote:
> >> Otherwise compiling in debugging will cause a _lot_ of spurious
> >> register reads to occur that are then tossed. This was one of the big
> >> reasons for instability and slow performance when AH_DEBUG was
> >> enabled.
> > That doesn't make any sense in this case.
> >
> > It's either a call to printk or _ath5_printk
> > but it's still a call to a function.
> 
> The FreeBSD HAL used to be like this. I changed it so it didn't
> evaluate the arguments before it figured out whether or not to do the
> (k)printf().
> 
> I'm just pointing it out as you're (currently) knee deep in the
> debugging code and it may be useful for you to also think about
> implementing.

I see, thanks for the heads-up.

The no_printk function could/does eval args
and can cause those sorts of issues.

So care does need to be used.

cheers, Joe
