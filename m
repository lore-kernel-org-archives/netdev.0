From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH ipsec 0/3] vti/vti6: minor tweaks + one fix
Date: Mon, 30 Jun 2014 11:19:13 +0200
Message-ID: <20140630091913.GO32371@secunet.com>
References: <1399671822-12842-1-git-send-email-minipli@googlemail.com>
 <20140513084114.GZ32371@secunet.com>
 <CA+rthh_bMBk8mC3FWgNrGtnnyN_tMa8scoXvkFGzV0OA6ug_bg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Mathias Krause <minipli@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:58483 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751514AbaF3JTU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jun 2014 05:19:20 -0400
Content-Disposition: inline
In-Reply-To: <CA+rthh_bMBk8mC3FWgNrGtnnyN_tMa8scoXvkFGzV0OA6ug_bg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 13, 2014 at 10:38:32PM +0200, Mathias Krause wrote:
> On 13 May 2014 10:41, Steffen Klassert <steffen.klassert@secunet.com> wrote:
> > On Fri, May 09, 2014 at 11:43:39PM +0200, Mathias Krause wrote:
> >> Hi Steffen,
> >>
> >> this series addresses a few issues related to VTI. The first patch fixes
> >> a bug in the vti6 module calling unregister_pernet_device() twice in the
> >> error path. That's probably material for ipsec.git.
> >> The second patch simplifies the error handling path in module init/fini
> >> of vti6. The third patch does the same for vti. Those two are probably
> >> material for ipsec-next.git as we're at -rc5 already. But I leave that
> >> decision to you.
> >
> > Right, patches two and three should go to ipsec-next. But the second
> > patch does not apply without the first patch. Please send separate
> > patchsets for ipsec and ipsec-next in future.
> 
> Patch 2 depends on patch 1 because it's a series ;) I explicitly
> didn't want to create different patches for ipsec-next because I
> wanted to avoid the merge conflicts on your side when ipsec-next would
> rebase to/merge a tree which would contain patch 1.
> One way to solve it would be to merge ipsec/master into
> ipsec-next/master prior to applying patches 2 and 3 -- just as Dave
> does with net-next from time to time, i.e. merging net/master. Another
> way would be to wait until Dave has merged ipsec/master into
> net/master and after that, has merged net/master into net-next. This
> way you can merge net-next into ipsec-next and after that apply
> patches 2 and 3 without conflicts. Your choice. You know the
> interdependencies between these trees better than me. But the first
> solution sounds simpler to me. ;)
> 

I've applied the remaining two patches to ipsec-next now, thanks!
