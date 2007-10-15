From: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
Subject: Re: [2.6 patch] __inet6_csk_dst_store(): fix check-after-use
Date: Mon, 15 Oct 2007 12:37:49 +0900 (JST)
Message-ID: <20071015.123749.497715418.takamiya@po.ntts.co.jp>
References: <20071014175212.GP4211@stusta.de>
	<20071015113723.00F7.NAKAM@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bunk@kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: nakam@linux-ipv6.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1764543AbXJOD5S@vger.kernel.org>
In-Reply-To: <20071015113723.00F7.NAKAM@linux-ipv6.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

>> Mon, 15 Oct 2007 11:45:10 +0900
>> [Subject: Re: [2.6 patch] __inet6_csk_dst_store(): fix check-after-use]
>> Masahide NAKAMURA <nakam@linux-ipv6.org> wrote...

> 
> On Sun, 14 Oct 2007 19:52:12 +0200
> Adrian Bunk <bunk@kernel.org> wrote:
> 
> > The Coverity checker spotted that we have already oops'ed if "dst"
> > was NULL.
> > 
> > Since "dst" being NULL doesn't seem to be possible at this point this 
> > patch removes the NULL check.
> > 
> > Signed-off-by: Adrian Bunk <bunk@stusta.de>
> 
> Agreed.
> 
> Acked-by: Masahide NAKAMURA <nakam@linux-ipv6.org>

  I also agreed.
  
Acked-by: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>

--
Noriaki TAKAMIYA
