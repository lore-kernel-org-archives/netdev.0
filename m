From: David Brownell <david-b@pacbell.net>
Subject: Re: netlink tester program
Date: Mon, 02 Jun 2003 20:34:19 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <3EDC173B.80909@pacbell.net>
References: <20030602140452.039248de.rddunlap@osdl.org>	<20030602.145619.71112623.davem@redhat.com>	<3EDC0047.7030007@pacbell.net> <20030602.190240.74724523.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rddunlap@osdl.org, linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
List-Id: netdev.vger.kernel.org


>    Well, the difference between code and its spec is
>    generally a bug that needs to be fixed ...
> 
> See, a document is NOT the spec, the code is the spec.

That's hardly the only development model.


> Because where the document is wrong, the code determines
> the final answer.  This is true in all cases.

Not "all".  "Code-as-spec" works well when there's only
one code base, but otherwise it's flawed.  Even the model
of a "reference implementation" is trouble ... since it
invariably evolves into "everyone should use this code".

Of course, bugs that stay unfixed for a long time can
force the "spec" to change.  It's a great vendor lock-in
tool, and it can happen accidentally too.  But most folk
view such interop problems as bugs, not features.


> I cannot tell you how much time I've seen people waste because they
> went for documents first, only to find them to be inaccurate for some
> corner case whilst the code has all of the accurate answers.

Or where they notice the code is wrong in that corner case,
and they can prove that easily since the spec (implemented
correctly in several other places) and the code disagree.

Or where this implementation uses this answer, and that one
uses that answer ... and the poor user gets caught in the
middle of a finger pointing war, which can't be resolved
since each implementation's developers claim to be "the spec",
and the user eventually gives up saying "a pox on you all!"

You clipped out the text where I pointed out that bugs can
be in specs as well as code.  They can be fixed there, too.


> When I see someone want docs, I interpret this as "I don't want to
> have to think or have to comprehend something, I'm too lazy to read
> the code."  Well, such laziness leads the person in question only
> to be suscpetible to all of the inaccuracies and disconnect that
> always will exist between said docs (if they even exist) and the
> code.

That's an *extremely negative interpretation*, and while I've seen
people that are that lazy, they happen to be in the minority
of people I've known to ask for docs/specs.  (Thank the Gods!)

Consider one thing that docs/specs do that code can't:  give
the "30,000 foot view" rather than the "tree level view".  It's
not "lazy" to avoid using the tree-level view; sometimes such
low-level perspectives can be counterproductive.

People ask for docs for lots of reasons, and most of them have
nothing at all to do with laziness.

- Dave



