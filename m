From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: Re: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Thu, 22 Jun 2006 01:31:35 -0300
Message-ID: <39e6f6c70606212131y20a99e62wc3bbc569aabc78ab@mail.gmail.com>
References: <20060504.161148.44973535.davem@davemloft.net>
	 <200605161102.29472.kelly@au.ibm.com>
	 <20060515.221637.90861876.davem@davemloft.net>
	 <200606221205.35161.kelly@au.ibm.com>
	 <Pine.LNX.4.64.0606212354420.15426@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kelly Daly" <kelly@au1.ibm.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.228]:6696 "EHLO
	wr-out-0506.google.com") by vger.kernel.org with ESMTP
	id S932788AbWFVEbg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 00:31:36 -0400
Received: by wr-out-0506.google.com with SMTP id i31so302576wra
        for <netdev@vger.kernel.org>; Wed, 21 Jun 2006 21:31:35 -0700 (PDT)
To: "James Morris" <jmorris@namei.org>
In-Reply-To: <Pine.LNX.4.64.0606212354420.15426@d.namei>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/22/06, James Morris <jmorris@namei.org> wrote:
> On Thu, 22 Jun 2006, Kelly Daly wrote:
>
> > +     switch (bp->netchan_buf_proto) {
> > +     case __constant_htons(ETH_P_IP): {
>
> __constant_htons and friends should not be used in runtime code, only for
> data being initialized at compile time.

... because they generate the same code, so, to make source code less
cluttered  ... :-)

- Arnaldo
