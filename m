From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [net-next-2.6 PATCH v5 5/5 RFC] TCPCT part1e: initial SYN exchange
 with SYNACK data
Date: Tue, 10 Nov 2009 16:00:43 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0911101559430.20637@melkinpaasi.cs.helsinki.fi>
References: <4AF83E2D.1050401@gmail.com> <4AF84BF3.5020302@gmail.com> <alpine.DEB.2.00.0911100659470.7059@melkinpaasi.cs.helsinki.fi> <4AF96D71.8000905@gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696230645-593299827-1257861643=:20637"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Joe Perches <joe@perches.com>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:35815 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755544AbZKJOAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 09:00:39 -0500
In-Reply-To: <4AF96D71.8000905@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696230645-593299827-1257861643=:20637
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Tue, 10 Nov 2009, William Allen Simpson wrote:

> Ilpo Järvinen wrote:
> > On Mon, 9 Nov 2009, William Allen Simpson wrote:
> > > ...
> > > Data structures are carefully composed to require minimal additions.
> > > For example, the struct tcp_options_received cookie_plus variable fits
> > > between existing 16-bit and 8-bit variables, requiring no additional
> > > space (taking alignment into consideration).  There are no additions to
> > > tcp_request_sock, and only 1 pointer in tcp_sock.
> > > ...
> > 
> > One general comment. ...This particular patch still has lots of noise which
> > does not belong to the context of this change. ...Please try to minimize.
> > Eg., if you don't like sizeof(struct tcphdr) but prefer sizeof(*th), you
> > certainly don't have to do it in this particular patch!
> 
> This *is* actually in CodingStyle (line 679), and I'm trying to conform:

I skipped reading after this statement.... Please re-read what I said.

-- 
 i.
---696230645-593299827-1257861643=:20637--
