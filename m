From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] more CONFIG_NET removals
Date: Tue, 24 Jun 2003 14:41:02 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030624.144102.08348088.davem@redhat.com>
References: <20030620112504.GM24357@parcelfarce.linux.theplanet.co.uk>
	<Mutt.LNX.4.44.0306242158250.6102-100000@excalibur.intercode.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: willy@debian.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jmorris@intercode.com.au
In-Reply-To: <Mutt.LNX.4.44.0306242158250.6102-100000@excalibur.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: James Morris <jmorris@intercode.com.au>
   Date: Tue, 24 Jun 2003 22:01:25 +1000 (EST)

   Some of the net/compat.c functions (e.g. compat_sys_setsockopt) are 
   still needed to allow the kernel to build.  Perhaps use cond_syscall() for 
   these?

Agreed.  You can't get rid of net/compat.o so easily.
