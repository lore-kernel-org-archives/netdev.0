From: Jindrich Makovicka <makovick@gmail.com>
Subject: Re: [REGRESSION]linux-2.6.35-rc3 in net/core/dev.c
Date: Sun, 13 Jun 2010 16:54:21 +0200
Message-ID: <20100613165421.7e8dda79@holly>
References: <201006131625.55481.mitov@issp.bas.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201006131625.55481.mitov@issp.bas.bg>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 13 Jun 2010 16:25:54 +0300
Marin Mitov <mitov@issp.bas.bg> wrote:

> Hi all,
> 
> I am using ssh with port redirection to log on host_at_work:
> 
> ssh -L20110:mail:110 host_at_work
> 
> With linux-2.6.35-rc3, when I telnet to localhost I get:
> 
> telnet localhost 20110
> Trying 127.0.0.1...
> telnet: connect to address 127.0.0.1: Connection timed out
[...]
> 
> I have seen the posting on LKML:
> 
> http://lkml.org/lkml/2010/6/13/11
> 
> and decided to revert the patch mentioned their (see bellow).
> The revert solves the problem for me.

I can confirm this. Reverting of this patch fixes a regression with
Privoxy running on localhost, where most of the connections
(browser->proxy) stall and don't return anything.

-- 
Jindrich Makovicka
