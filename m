From: Mitchell Blank Jr <mitch@sfgoth.com>
Subject: Re: [PATCH] tiny af_packet.c cleanup
Date: Sat, 13 Sep 2003 01:02:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030913080252.GE94744@gaz.sfgoth.com>
References: <20030913055033.GB94744@gaz.sfgoth.com> <20030913093559.A23840@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20030913093559.A23840@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> 2 - I am not completely convinced that the "/* re-check under lock */" 
>     comment is really useful either: the lock statement is on the line before.

I thought that without the comment someone might think that the second
"if()" wasn't needed (since we had just checked the same value against
NULL a few lines up)

-Mitch
