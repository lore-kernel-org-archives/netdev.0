From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Subject: Re: [PATCH] IPv6/DCCP: Remove unused IPV6_PKTOPTIONS code
Date: Fri, 29 Sep 2006 11:40:43 -0300
Message-ID: <39e6f6c70609290740s79bf0b1cwe0b64eef8074eeeb@mail.gmail.com>
References: <200609290245.33618.jesper.juhl@gmail.com>
	 <20060928230751.99041004.akpm@osdl.org>
	 <200609291102.19243@strip-the-willow>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@osdl.org>,
	"Ian McDonald" <ian.mcdonald@jandi.co.nz>,
	"Jesper Juhl" <jesper.juhl@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	dccp@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	"Pekka Savola" <pekkas@netcore.fi>,
	"James Morris" <jmorris@namei.org>,
	"Hideaki YOSHIFUJI" <yoshfuji@linux-ipv6.org>,
	"Patrick McHardy" <kaber@coreworks.de>,
	"Alexey Kuznetsov" <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.230]:46953 "EHLO
	wx-out-0506.google.com") by vger.kernel.org with ESMTP
	id S1751134AbWI2Okn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 10:40:43 -0400
Received: by wx-out-0506.google.com with SMTP id s14so961943wxc
        for <netdev@vger.kernel.org>; Fri, 29 Sep 2006 07:40:43 -0700 (PDT)
To: "Gerrit Renker" <gerrit@erg.abdn.ac.uk>
In-Reply-To: <200609291102.19243@strip-the-willow>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/29/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> >  Coverity found what looks like a real leak in net/dccp/ipv6.c::dccp_v6_do_rcv()
>
> |  otoh, it seems to me that opt_skb doesn't actually do anything and can be
> |  removed?
> This is right, there is no code referencing opt_skb: compare with net/ipv6/tcp_ipv6.c.
> Until someone has time to add the missing DCCP-specific code, it does seem better
> to replace the dead part with a FIXME. This is done by the patch below, applies to
> davem-net2.6 and has been tested to compile.

Thanks, I've been again sidetracked by Real Life(tm) but hopefully
tomorrow I'll go over all the DCCP pending patches backlog and get
them into tree to submit to Dave.

- Arnaldo
