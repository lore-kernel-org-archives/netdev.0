From: Brenden Blanco <bblanco@plumgrid.com>
Subject: Re: [PATCH v7 01/11] bpf: add XDP prog type for early driver filter
Date: Mon, 11 Jul 2016 23:26:14 -0700
Message-ID: <20160712062613.GA20499@gmail.com>
References: <1468272598-21390-1-git-send-email-bblanco@plumgrid.com>
 <1468272598-21390-2-git-send-email-bblanco@plumgrid.com>
 <20160711.230254.53567533766522969.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jhs@mojatatu.com,
	saeedm@dev.mellanox.co.il, kafai@fb.com, brouer@redhat.com,
	as754m@att.com, alexei.starovoitov@gmail.com, gerlitz.or@gmail.com,
	john.fastabend@gmail.com, hannes@stressinduktion.org,
	tgraf@suug.ch, tom@herbertland.com, daniel@iogearbox.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33234 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753201AbcGLG0S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 02:26:18 -0400
Received: by mail-pa0-f41.google.com with SMTP id ks6so3322836pab.0
        for <netdev@vger.kernel.org>; Mon, 11 Jul 2016 23:26:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160711.230254.53567533766522969.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 11, 2016 at 11:02:54PM -0700, David Miller wrote:
> From: Brenden Blanco <bblanco@plumgrid.com>
> Date: Mon, 11 Jul 2016 14:29:48 -0700
> 
> > +	WARN_ONCE(1, "\n"
> > +		     "*****************************************************\n"
> > +		     "**   NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE   **\n"
> > +		     "**                                               **\n"
> > +		     "** XDP program returned unknown value %-10u **\n"
> > +		     "**                                               **\n"
> > +		     "** XDP programs must return a well-known return  **\n"
> > +		     "** value. Invalid return values will result in   **\n"
> > +		     "** packet loss.                                  **\n"
> > +		     "**                                               **\n"
> > +		     "**   NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE   **\n"
> > +		     "*****************************************************\n",
> 
> This is rediculous.
> 
> The log message should be concise, one line, and not scream things
> like "NOTICE".  That's what the log level is for, to indicate the
> severity of the issue.
Makes sense, and I won't try this approach again. The caller of this
code continues to be much debated as well.
