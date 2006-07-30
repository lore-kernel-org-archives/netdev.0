From: "Jesper Juhl" <jesper.juhl@gmail.com>
Subject: Re: [PATCH] fix memory leak in net/ipv4/tcp_probe.c::tcpprobe_read()
Date: Sun, 30 Jul 2006 23:51:20 +0200
Message-ID: <9a8748490607301451j21589110ifd8677f328b7eba6@mail.gmail.com>
References: <200607302138.02855.jesper.juhl@gmail.com>
	 <20060730142922.7c1d4f7d@localhost.localdomain>
	 <Pine.LNX.4.64.0607301747170.26424@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Stephen Hemminger" <shemminger@osdl.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Alexey Kuznetsov" <kuznet@ms2.inr.ac.ru>,
	"Hideaki YOSHIFUJI" <yoshfuji@linux-ipv6.org>,
	"Pekka Savola" <pekkas@netcore.fi>,
	"Patrick McHardy" <kaber@coreworks.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:21412 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S932426AbWG3VvV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Jul 2006 17:51:21 -0400
Received: by ug-out-1314.google.com with SMTP id m3so469978ugc
        for <netdev@vger.kernel.org>; Sun, 30 Jul 2006 14:51:20 -0700 (PDT)
To: "James Morris" <jmorris@namei.org>
In-Reply-To: <Pine.LNX.4.64.0607301747170.26424@d.namei>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 30/07/06, James Morris <jmorris@namei.org> wrote:
> On Sun, 30 Jul 2006, Stephen Hemminger wrote:
>
> > On Sun, 30 Jul 2006 21:38:02 +0200
> > Jesper Juhl <jesper.juhl@gmail.com> wrote:
> >
> > > There's an obvious memory leak in net/ipv4/tcp_probe.c::tcpprobe_read()
> > > We are not freeing 'tbuf' on error.
> > > Patch below fixes that.
> > >
> > >
> > > Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
> > Agreed, thanks for catching it.  The whole kfifo interface is kind of
> > annoying have to do an extra copy.
>
> Might be cleaner to make a single return path for cleanup:
>
> Signed-off-by: James Morris <jmorris@namei.org>
>
Looks ok to me.

-- 
Jesper Juhl <jesper.juhl@gmail.com>
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please      http://www.expita.com/nomime.html
