From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] LSM networking: tcp hooks for 2.5.59 (8/8)
Date: Thu, 30 Jan 2003 15:25:58 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030130.152558.81554884.davem@redhat.com>
References: <Pine.LNX.4.44.0301311010580.31382-100000@blackbird.intercode.com.au>
	<Pine.LNX.4.44.0301311017140.31802-100000@blackbird.intercode.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, linux-security-module@wirex.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jmorris@intercode.com.au
In-Reply-To: <Pine.LNX.4.44.0301311017140.31802-100000@blackbird.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


No, no, and no.

This stuff will not pass.

There is no way in hell we're going to insert this security crap into
the actual protocol implementations.  I was right in seeing this as a
virus that will eventually infect the whole tree.

None of these security modules should know jack anything about open
requests and other TCP internals.

This stuff is totally unmaintainable garbage.  And I do not want to
hear "well how can we implement xxx which we need for yyy" because it
isn't my problem that you can't figure out a clean way to do this
stuff.

Linus would similarly barf if he was given a patch that added
hooks like "security_ext2_foo()".

I totally reject this networking security stuff for 2.6.x
