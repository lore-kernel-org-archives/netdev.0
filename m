From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 1/1] NET: llc, zero sockaddr_llc struct
Date: Sun, 23 Aug 2009 23:20:28 -0300
Message-ID: <20090824022028.GE6709@ghostprotocols.net>
References: <1250967535-30692-1-git-send-email-jirislaby@gmail.com> <20090823.185617.36449822.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jirislaby@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751296AbZHXCUe@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090823.185617.36449822.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Sun, Aug 23, 2009 at 06:56:17PM -0700, David Miller escreveu:
> From: Jiri Slaby <jirislaby@gmail.com>
> Date: Sat, 22 Aug 2009 20:58:55 +0200
> 
> > sllc_arphrd member of sockaddr_llc might not be set. Zero sllc
> > before copying it to the above layers.
> > 
> > Signed-off-by: Jiri Slaby <jirislaby@gmail.com>
> > Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
> 
> I know it seems arbitrary, but could you please memset() on the
> structure instead of using an empty initializer so that it's
> consistent with how all other ->getname() implementations deal with
> this issue?
> 
> It's easier to audit that way.

Or just set the uninitialized field to zero. But yeah, if what other
implementations are doing is to memset it to zero... maybe its more
clear from a quick glance :-)

- Arnaldo
