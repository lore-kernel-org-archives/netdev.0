From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 1/1] lib/test_bpf.c: don't use gcc union shortcut
Date: Thu, 22 May 2014 10:58:49 -0700
Message-ID: <20140522105849.182e99b7cb973a7ba95375db@linux-foundation.org>
References: <20140522171646.843C831C19E@corp2gmr1-1.hot.corp.google.com>
	<CAMEtUux+C+1wSeiFpo-Q+=KxeZ8WQEnFaF-4a8W2fxjO8Hwj0w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Daniel Borkmann <dborkman@redhat.com>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:58872 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751153AbaEVR6w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 13:58:52 -0400
In-Reply-To: <CAMEtUux+C+1wSeiFpo-Q+=KxeZ8WQEnFaF-4a8W2fxjO8Hwj0w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 22 May 2014 10:36:40 -0700 Alexei Starovoitov <ast@plumgrid.com> wrote:

> On Thu, May 22, 2014 at 10:16 AM,  <akpm@linux-foundation.org> wrote:
> > From: Andrew Morton <akpm@linux-foundation.org>
> > Subject: lib/test_bpf.c: don't use gcc union shortcut
> >
> > Older gcc's (mine is gcc-4.4.4) make a mess of this.
> >
> > lib/test_bpf.c:74: error: unknown field 'insns' specified in initializer
> > lib/test_bpf.c:75: warning: missing braces around initializer
> > lib/test_bpf.c:75: warning: (near initialization for 'tests[0].<anonymous>.insns[0]')
> > lib/test_bpf.c:76: error: extra brace group at end of initializer
> > lib/test_bpf.c:76: error: (near initialization for 'tests[0].<anonymous>')
> > lib/test_bpf.c:76: warning: excess elements in union initializer
> > lib/test_bpf.c:76: warning: (near initialization for 'tests[0].<anonymous>')
> > lib/test_bpf.c:77: error: extra brace group at end of initializer
> >
> > Cc: Alexei Starovoitov <ast@plumgrid.com>
> > Cc: David S. Miller <davem@davemloft.net>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> 
> I didn't know we still want to support such old versions.
> gcc 4.4 was released in 2009.

Well, gcc-4.4 fails but I don't know about later versions.

> What is the official cutoff for gcc ?

We're really slack about tracking this.  Documentation/Changes says gcc-3.2!
