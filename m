From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Subject: Re: [PATCH] Re: fealnx oopses
Date: Fri, 26 Mar 2004 22:05:53 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200403262205.53503.vda@port.imtp.ilyichevsk.odessa.ua>
References: <200403261214.58127.vda@port.imtp.ilyichevsk.odessa.ua> <20040326192211.GA15319@scream.fjortis.info> <4064857E.2050603@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Marcelo Tosatti <marcelo@conectiva.com.br>,
        Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Andreas Henriksson <andreas@fjortis.info>
In-Reply-To: <4064857E.2050603@pobox.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Friday 26 March 2004 21:33, Jeff Garzik wrote:
> > Although I now have the myson/fealnx card in my p3-900 (256Mb)
> > workstation instead of the old p-166 (40Mb) which served as a gateway
> > before. It might just be that it's harder to trigger on newer/bigger
> > machines. Maybee I should power up my p-166 again.. I actually have 2 of
> > these cards so I can have one in each machine.. :)
>
> Well really, somebody needs to port Donald Becker's myson driver to 2.6
> APIs...  I would like to get rid of fealnx, or somebody needs to spend a
> decent amount of time fixing it.
>
> Does the attached patch fix the issue?
>
> 	Jeff

It may fix Andreas case, but I doubt it can fix mine -
mine was related to _rx_ code path.

I need to find a way to reliably reproduce oopses with unfixed driver first.
--
vda
