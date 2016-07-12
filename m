From: Brenden Blanco <bblanco@plumgrid.com>
Subject: Re: [PATCH v7 04/11] net/mlx4_en: add support for fast rx drop bpf
 program
Date: Tue, 12 Jul 2016 09:31:21 -0700
Message-ID: <20160712163118.GA13865@gmail.com>
References: <1468272598-21390-1-git-send-email-bblanco@plumgrid.com>
 <1468272598-21390-5-git-send-email-bblanco@plumgrid.com>
 <20160711.231700.1668856499968096629.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jhs@mojatatu.com,
	saeedm@dev.mellanox.co.il, kafai@fb.com, brouer@redhat.com,
	as754m@att.com, alexei.starovoitov@gmail.com, gerlitz.or@gmail.com,
	john.fastabend@gmail.com, hannes@stressinduktion.org,
	tgraf@suug.ch, tom@herbertland.com, daniel@iogearbox.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:34890 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750816AbcGLQb3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 12:31:29 -0400
Received: by mail-pf0-f173.google.com with SMTP id c2so8621824pfa.2
        for <netdev@vger.kernel.org>; Tue, 12 Jul 2016 09:31:24 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160711.231700.1668856499968096629.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 11, 2016 at 11:17:00PM -0700, David Miller wrote:
> From: Brenden Blanco <bblanco@plumgrid.com>
> Date: Mon, 11 Jul 2016 14:29:51 -0700
> 
> > +	if (priv->num_frags > 1)
> > +		return -EOPNOTSUPP;
> 
> I hate to be the user who has to debug why his XDP program won't
> load just because he set a jumbo MTU beforehand.
Me too. Patch v8 now has an en_err message, and double checked that a
message is printed when MTU is attempted to be increased when XDP
program has already been loaded.

Thanks.
