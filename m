From: "David S. Miller" <davem@redhat.com>
Subject: Re: link error building kernel with gcc-3.3
Date: Wed, 14 May 2003 22:42:14 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030514.224214.42791773.davem@redhat.com>
References: <20030514202941.39519.qmail@web40503.mail.yahoo.com>
	<Mutt.LNX.4.44.0305151536280.12417-100000@excalibur.intercode.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex14641@yahoo.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jmorris@intercode.com.au
In-Reply-To: <Mutt.LNX.4.44.0305151536280.12417-100000@excalibur.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: James Morris <jmorris@intercode.com.au>
   Date: Thu, 15 May 2003 15:38:15 +1000 (EST)
   
   I wonder, does this mean that the compiler failed to inline the function?
   
   Removing __inline__ is not the correct solution.
   
I already posted what the correct fix is :-)  And this is already
pushed to 2.5.x

Inlining is not guarenteed, and:

extern inline ... foo(...)

means "inline if you can, I have a compiled-in implementation
in some object somewhere" whereas:

static inline ... foo(...)

means "inline if you can, if there is a case where you cannot
emit this as a function into the current module"
