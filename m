From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] tc: fix parallel build file with lex/yacc
Date: Tue, 18 Oct 2011 15:02:46 -0700
Message-ID: <20111018150246.739236ec@nehalam.linuxnetplumber.net>
References: <1318973888-29496-1-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: stephen.hemminger@vyatta.com, netdev@vger.kernel.org
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45405 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753758Ab1JRWCt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Oct 2011 18:02:49 -0400
In-Reply-To: <1318973888-29496-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 18 Oct 2011 17:38:08 -0400
Mike Frysinger <vapier@gentoo.org> wrote:

> Building iproute2 in parallel might hit the race failure:
> 	emp_ematch.l:2:30: fatal error: emp_ematch.yacc.h:
> 		No such file or directory
> 	make[1]: *** [emp_ematch.lex.o] Error 1
> 
> This is because we currently allow the yacc/lex files to generate and
> compile in parallel.  So add a simple dependency to make sure yacc has
> finished before we attempt to compile the lex output.
> 
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>

applied
