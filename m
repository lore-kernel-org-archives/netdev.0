From: <akepner@sgi.com>
Subject: Re: [PATCH] use mmiowb in tg3.c
Date: Thu, 21 Oct 2004 18:33:22 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.33.0410211826480.392-100000@localhost.localdomain>
References: <1098407804.6071.22.camel@gaston>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
        Jesse Barnes <jbarnes@engr.sgi.com>, Andrew Morton <akpm@osdl.org>,
        Linux Kernel list <linux-kernel@vger.kernel.org>, <netdev@oss.sgi.com>,
        Jeff Garzik <jgarzik@pobox.com>, <gnb@sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <1098407804.6071.22.camel@gaston>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 22 Oct 2004, Benjamin Herrenschmidt wrote:

> ... 
> Typically, our normal "light" write barrier doesn't reorder between cacheable
> and non-cacheable (MMIO) stores, which is why we had to put some heavy sync
> barrier in our MMIO writes macros.
> ...

Do you mean "impose order" rather than "reorder" here? 

-- 
Arthur
