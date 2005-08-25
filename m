From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: Route cache performance
Date: Fri, 26 Aug 2005 00:05:43 +0400
Message-ID: <20050825200543.GA6612@yakov.inr.ac.ru>
References: <20050815213855.GA17832@netnation.com> <43014E27.1070104@cosmosbay.com> <20050823190852.GA20794@netnation.com> <17163.32645.202453.145416@robur.slu.se> <20050824000158.GA8137@netnation.com> <20050825181111.GB14336@netnation.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, kuznet@ms2.inr.ac.ru,
        Eric Dumazet <dada1@cosmosbay.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Simon Kirby <sim@netnation.com>
Content-Disposition: inline
In-Reply-To: <20050825181111.GB14336@netnation.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> something is holding the refcnt > 0 for almost all of the entries that
> rt_garbage_collect() walks.

Did you try to look at output of "ip -s -s ro ls ca" ?
If it is just a refcnt leakage, leaked routes should appear there
and it is possible to guess, where they leaked.

Alexey
