From: Brandon Philips <brandon@ifup.org>
Subject: Re: dmfe/tulip device id overlap
Date: Sun, 29 Nov 2009 22:55:12 -0800
Message-ID: <20091130065512.GA2792@jenkins.domain_not_set.invalid>
References: <20091125043603.GK14043@jenkins.home.ifup.org>
 <20091125044944.GL14043@jenkins.home.ifup.org>
 <da824cf30911250924i31f77033r7f60027ed74b2cd@mail.gmail.com>
 <20091129.003024.245104886.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: grundler@google.com, tobias@ringis.se, kyle@mcmartin.ca,
	netdev@vger.kernel.org, grundler@parisc-linux.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f182.google.com ([209.85.211.182]:51759 "EHLO
	mail-yw0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752470AbZK3GzT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 01:55:19 -0500
Received: by ywh12 with SMTP id 12so3611905ywh.21
        for <netdev@vger.kernel.org>; Sun, 29 Nov 2009 22:55:25 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20091129.003024.245104886.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Dave-

On 00:30 Sun 29 Nov 2009, David Miller wrote:
> From: Grant Grundler <grundler@google.com>
> Date: Wed, 25 Nov 2009 09:24:54 -0800
> 
> > I'm ok with this patch except the mention of Ubuntu in the comment is
> > superfluous. All the distro's will share this problem. I trust davem
> > to rewrite the comment and plase add my:
> >     Signed-off-by: Grant Grundler <grundler@parisc-linux.org>
> 
> Please remove the comment and the __sparc__ ifdef.

The comment and the __sparc__ ifdef is the entire patch... so you NACK
the whole patch?? ;)

> If tulip doesn't work on some sparc systems we simply need to fix
> it.

Tulip works on sparc as described in the linux-sparc[1] thread.  The
problem as I understand it:

tulip works for the 0x9100 and 0x9102 parts that were onboard a few
sparc motherboards.

But, those same device IDs are used by a set of Davicom PCI cards that
only work with the dmfe driver.

Thus, the patch only lets tulip handle 0x9100 and 0x9102 if __sparc__.

Perhaps someone knows if there is a way to tell the PCI card from the
sparc builtin machine?

Cheers,

	Brandon

[1] http://marc.info/?l=linux-sparc&m=123698696912216&w=2
