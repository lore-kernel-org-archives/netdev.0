From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [PATCH] make tg3 NAPI support configurable
Date: Mon, 12 Jan 2004 11:12:35 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4001E673.59994F40@melbourne.sgi.com>
References: <3FE2F3A7.2A109F28@melbourne.sgi.com> <16354.64258.364153.488309@robur.slu.se> <4000ABBA.50601@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        "David S. Miller" <davem@redhat.com>,
        Linux Network Development list <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> 
> Robert Olsson wrote:
> >  You can use coalescing with NAPI as well, e1000 and other drivers
> >  are doing this. This will give you same interrupt rates as non-
> >  NAPI at low load and "polling" without any interrupts at high load.
> 
> Yes, this is something I've been meaning to add to tg3 for months now.

I'd be very happy to test patches on an Altix, where this issue is a
significant networking scaling limitation.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.
