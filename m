From: David Miller <davem@davemloft.net>
Subject: Re: Don't leak 'listeners' in netlink_kernel_create()
Date: Mon, 15 Oct 2007 01:39:24 -0700 (PDT)
Message-ID: <20071015.013924.48816492.davem@davemloft.net>
References: <200710142337.01059.jesper.juhl@gmail.com>
	<m1hckt5nyp.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesper.juhl@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, alan@redhat.com, kuznet@ms2.inr.ac.ru
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54528
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755305AbXJOIjT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 04:39:19 -0400
In-Reply-To: <m1hckt5nyp.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sun, 14 Oct 2007 16:30:06 -0600

> Jesper Juhl <jesper.juhl@gmail.com> writes:
> 
> > From: Jesper Juhl <jesper.juhl@gmail.com>
> > Subject: Don't leak 'listeners' in netlink_kernel_create()
> >
> > The Coverity checker spotted that we'll leak the storage allocated 
> > to 'listeners' in netlink_kernel_create() when the
> >   if (!nl_table[unit].registered)
> > check is false.
> >
> > This patch avoids the leak.
> >
> >
> > Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
> 
> This patch appears trivially correct to me.
> Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>

Applied, thanks everyone.
