From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] pktgen: Use seq_puts() where seq_printf() is
 not needed
Date: Fri, 16 May 2014 16:23:46 +0100
Message-ID: <20140516152346.GF8346@casper.infradead.org>
References: <090215cd09d88cd79c4e37ff2cc9f7da58205f76.1400237005.git.tgraf@suug.ch>
 <CAADnVQJfmDqeayQUaL7KZLjnQQu8QTiYKJ5wkrMxWdgvKNx8ug@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D1724771A@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 'Alexei Starovoitov' <alexei.starovoitov@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:40185 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755910AbaEPPXr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 11:23:47 -0400
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1724771A@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/16/14 at 03:08pm, David Laight wrote:
> From: Alexei Starovoitov
> > > -       seq_printf(seq, "dst_mac: ");
> > > +       seq_puts(seq, "dst_mac: ");
> > 
> > tough luck of kernel developers... ;)
> > Normal printf() GCC optimizes into puts() automatically.
> 
> Yes - a PITA when you are compiling for an embedded system
> with a very limited 'libc'.
> 
> Unless I was actually worried about the execution time I'd
> leave them as seq_printf() for consistency through the function.

pktgen already used seq_puts() in various places but not
consistently. Now it does. Besides that, checkpatch.pl specifically
complained about the use of seq_printf() on non format strings.
