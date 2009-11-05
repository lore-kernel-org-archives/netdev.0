From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCHv6 1/3] tun: export underlying socket
Date: Thu, 5 Nov 2009 12:30:43 +0100
Message-ID: <200911051230.43272.arnd@arndb.de>
References: <cover.1257193660.git.mst@redhat.com> <200911041909.06054.arnd@arndb.de> <20091104190523.GA772@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu,
	linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com,
	gregory.haskins@gmail.com, Rusty Russell <rusty@rustcorp.com.au>,
	s.hetze@linux-ag.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:63035 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753858AbZKELbE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2009 06:31:04 -0500
In-Reply-To: <20091104190523.GA772@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 04 November 2009, Michael S. Tsirkin wrote:
> > 
> > Michael, you didn't reply on this comment and the code is still there in v8.
> > Do you actually need this? What for?
> > 
> >       Arnd <><
> 
> Sorry, missed the question. If you look closely it is not exported for
> !__KERNEL__ at all.  The stub is for when CONFIG_TUN is undefined.
> Maybe I'll add a comment near #else, even though this is a bit strange
> since the #if is just 2 lines above it.

Ah right, I'm just blind.

Don't bother changing it then, the code looks good as it is.

	Arnd <><
