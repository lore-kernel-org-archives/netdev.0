From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] [RFC] Support for wccp version 1 and 2 in ip_gre.c
Date: Mon, 13 Sep 2004 16:19:12 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040913161912.7dcc809f.davem@davemloft.net>
References: <20040911194108.GS28258@stingr.sgu.ru>
	<20040912170505.62916147.davem@davemloft.net>
	<20040913051706.GB26337@stingr.sgu.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: i@stingr.net, netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S269057AbUIMXVF@vger.kernel.org>
To: Paul P Komkoff Jr <i@stingr.net>
In-Reply-To: <20040913051706.GB26337@stingr.sgu.ru>
List-Id: netdev.vger.kernel.org

On Mon, 13 Sep 2004 09:17:06 +0400
Paul P Komkoff Jr <i@stingr.net> wrote:

> Replying to David S. Miller:
> > What are the rules for IP_GRE in general for when
> > to apply this transformation?
> 
> As you can see, I am applying it unconditionally when fits. For most
> cases, this will be OK.
> There can be situations when this is not wanted (for example, when 
> debugging something), so in general, tuning knob will be useful, but 
> I just don't know where to add it, maybe tunnel->parms.i_flags ...

I don't think adding such a knob is necessary, but yes i_flags
would be the place to do it.

I will apply your patch with the "if(1)" simply removed.

Thanks.
