From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH stable <= 3.18] net: add length argument to
 skb_copy_and_csum_datagram_iovec
Date: Tue, 10 Nov 2015 16:03:52 -0800
Message-ID: <20151111000352.GA5134@kroah.com>
References: <c1b23313f94ba3fd9977c6fba61483edf6489b5f.1444910940.git.sd@queasysnail.net>
 <20151029100021.GA17588@bistromath.redhat.com>
 <CAKA=qzZCi_OEDJKgy1WQ1QdMBpHBure1tY7NYtsgSr0fMva5jQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sabrina Dubroca <sd@queasysnail.net>, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au, stable <stable@vger.kernel.org>,
	hannes@stressinduktion.org
To: Josh Hunt <joshhunt00@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:37583 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751835AbbKKADw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2015 19:03:52 -0500
Content-Disposition: inline
In-Reply-To: <CAKA=qzZCi_OEDJKgy1WQ1QdMBpHBure1tY7NYtsgSr0fMva5jQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 10, 2015 at 05:59:26PM -0600, Josh Hunt wrote:
> On Thu, Oct 29, 2015 at 5:00 AM, Sabrina Dubroca <sd@queasysnail.net> wrote:
> > 2015-10-15, 14:25:03 +0200, Sabrina Dubroca wrote:
> >> Without this length argument, we can read past the end of the iovec in
> >> memcpy_toiovec because we have no way of knowing the total length of the
> >> iovec's buffers.
> >>
> >> This is needed for stable kernels where 89c22d8c3b27 ("net: Fix skb
> >> csum races when peeking") has been backported but that don't have the
> >> ioviter conversion, which is almost all the stable trees <= 3.18.
> >>
> >> This also fixes a kernel crash for NFS servers when the client uses
> >>  -onfsvers=3,proto=udp to mount the export.
> >>
> >> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> >> Reviewed-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> >
> > Fixes CVE-2015-8019.
> > http://www.openwall.com/lists/oss-security/2015/10/29/1
> >
> > --
> > Sabrina
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> Greg
> 
> Do you have this in your queue? I saw a few other stables pick this
> up, but haven't seen it in 3.14 or 3.18 yet. It wasn't clear to me if
> this had been fully reviewed yet.

I rely on Dave to package up networking stable patches and forward them
on to me, that's why you haven't seen it be picked up yet.

thanks,

greg k-h
