From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] use mmiowb in tg3.c
Date: Fri, 22 Oct 2004 12:07:24 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1098410843.6028.45.camel@gaston>
References: <Pine.LNX.4.33.0410211826480.392-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Jesse Barnes <jbarnes@engr.sgi.com>, Andrew Morton <akpm@osdl.org>,
        Linux Kernel list <linux-kernel@vger.kernel.org>, netdev@oss.sgi.com,
        Jeff Garzik <jgarzik@pobox.com>, gnb@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: akepner@sgi.com
In-Reply-To: <Pine.LNX.4.33.0410211826480.392-100000@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2004-10-22 at 11:33, akepner@sgi.com wrote:
> On Fri, 22 Oct 2004, Benjamin Herrenschmidt wrote:
> 
> > ... 
> > Typically, our normal "light" write barrier doesn't reorder between cacheable
> > and non-cacheable (MMIO) stores, which is why we had to put some heavy sync
> > barrier in our MMIO writes macros.
> > ...
> 
> Do you mean "impose order" rather than "reorder" here? 

Right.

Ben.
