From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: 2.6.1-mm4
Date: Mon, 19 Jan 2004 22:42:19 +1100
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040119224219.65991501.rusty@rustcorp.com.au>
References: <20040115225948.6b994a48.akpm@osdl.org>
	<20040118001217.GE3125@werewolf.able.es>
	<20040117215535.0e4674b8.akpm@osdl.org>
	<20040118081128.GA3153@werewolf.able.es>
	<20040118001708.09291455.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jamagallon@able.es, linux-kernel@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20040118001708.09291455.akpm@osdl.org>
List-Id: netdev.vger.kernel.org

On Sun, 18 Jan 2004 00:17:08 -0800
Andrew Morton <akpm@osdl.org> wrote:

> Presumably, recent gcc's remove the variable altogether and just expand the
> constant inline.  When the central module code checks for the parameter's
> existence in the module's symbol table it errors out.

MODULE_PARM considered harmful.

Unfortunately, there's no easy way of fixing this, since MODULE_PARM()
is often used on variables which aren't declared yet 8(.  (I tried this
in an early patch).

Migrating to module_param() is the Right Thing here IMHO, which actually
takes the damn address,

Rusty.
-- 
   there are those who do and those who hang on and you don't see too
   many doers quoting their contemporaries.  -- Larry McVoy
