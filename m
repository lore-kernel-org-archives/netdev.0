From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH] ipvs: Use pointer to address from sync message
Date: Fri, 5 Sep 2008 14:28:48 +0200
Message-ID: <f4845fc0809050528q253789fbi60ca6c229a08d8ab@mail.gmail.com>
References: <1220363755-9854-1-git-send-email-juliusv@google.com>
	 <1220363755-9854-13-git-send-email-juliusv@google.com>
	 <alpine.LNX.2.00.0809051342360.18192@titan.stealer.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: horms@verge.net.au, netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org, kaber@trash.net, vbusam@google.com
To: "Sven Wegener" <sven.wegener@stealer.net>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.0809051342360.18192@titan.stealer.net>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 5, 2008 at 1:46 PM, Sven Wegener <sven.wegener@stealer.net> wrote:
> We want a pointer to it, not the value casted to a pointer.

Ouch, right!

> Signed-off-by: Sven Wegener <sven.wegener@stealer.net>
> ---
>  net/ipv4/ipvs/ip_vs_sync.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
>
> I've been too late with having a look at these patches. I'm going to
> send follow-up patches for the issues I find.

Thanks! There are probably still lots of these easy-to-miss (but bad)
bugs in this big new bunch of code...

> Simon, please apply onto lvs-next-2.6.

Yes!

Julius

-- 
Julius Volz - Corporate Operations - SysOps

Google Switzerland GmbH - Identification No.: CH-020.4.028.116-1
