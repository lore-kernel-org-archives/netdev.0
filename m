From: "David S. Miller" <davem@redhat.com>
Subject: Re: netlink tester program
Date: Mon, 02 Jun 2003 19:02:40 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030602.190240.74724523.davem@redhat.com>
References: <20030602140452.039248de.rddunlap@osdl.org>
	<20030602.145619.71112623.davem@redhat.com>
	<3EDC0047.7030007@pacbell.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rddunlap@osdl.org, linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: david-b@pacbell.net
In-Reply-To: <3EDC0047.7030007@pacbell.net>
List-Id: netdev.vger.kernel.org

   From: David Brownell <david-b@pacbell.net>
   Date: Mon, 02 Jun 2003 18:56:23 -0700
   
   Well, the difference between code and its spec is
   generally a bug that needs to be fixed ...

See, a document is NOT the spec, the code is the spec.

Because where the document is wrong, the code determines
the final answer.  This is true in all cases.

I cannot tell you how much time I've seen people waste because they
went for documents first, only to find them to be inaccurate for some
corner case whilst the code has all of the accurate answers.

When I see someone want docs, I interpret this as "I don't want to
have to think or have to comprehend something, I'm too lazy to read
the code."  Well, such laziness leads the person in question only
to be suscpetible to all of the inaccuracies and disconnect that
always will exist between said docs (if they even exist) and the
code.

It is also the mechanism that leads people to send patches that add
arbitrary crap all over the ipv4/ipv6 code, totally missing the point
that the routing and/or netlink layer did %99 of what they wanted
already.

For example, I added a hoplimit route attribute to RTNETLINK.  Who
documented this?  What document can you read that would teach you
about this feature?  None.

And don't tell me this is a doc bug, every time I make a change the
documentation will be instantly buggy and I'm not going to be required
to document every diff I make to the tree.
