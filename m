From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Subject: Re: [2.6 patch] kill net/rxrpc/rxrpc_syms.c
Date: Tue, 28 Nov 2006 01:54:43 -0200
Message-ID: <39e6f6c70611271954s7cc3b6bbo237e333ae0d810ea@mail.gmail.com>
References: <20061126040416.GH15364@stusta.de> <30354.1164626485@redhat.com>
	 <20061127193313.d59f61f0.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David Howells" <dhowells@redhat.com>,
	"Adrian Bunk" <bunk@stusta.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.228]:40089 "EHLO
	wx-out-0506.google.com") by vger.kernel.org with ESMTP
	id S935088AbWK1Dyo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Nov 2006 22:54:44 -0500
Received: by wx-out-0506.google.com with SMTP id h27so1882894wxd
        for <netdev@vger.kernel.org>; Mon, 27 Nov 2006 19:54:43 -0800 (PST)
To: "Andrew Morton" <akpm@osdl.org>
In-Reply-To: <20061127193313.d59f61f0.akpm@osdl.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/28/06, Andrew Morton <akpm@osdl.org> wrote:
> On Mon, 27 Nov 2006 11:21:25 +0000
> David Howells <dhowells@redhat.com> wrote:
>
> > Adrian Bunk <bunk@stusta.de> wrote:
> >
> > > This patch moves the EXPORT_SYMBOL's from net/rxrpc/rxrpc_syms.c to the
> > > files with the actual functions.
> >
> > You can if you like.  Can you slap a blank line before each EXPORT_SYMBOL()
> > though please?
>
> We have a mixture of both styles and given that they waste space in return
> for no added value, people have been gradually removing these blank lines
> in many places.  Please don't add more.

Agreed, good thing would be if we could have something like

void foo(int bar) gpl_exported
{
}

I.e. some kind of __attribute__, nah, I should just get some sleep :-)

- Arnaldo
