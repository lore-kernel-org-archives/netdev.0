From: Ramon Casellas <casellas@infres.enst.fr>
Subject: Re: [ANNOUNCE] Porting MPLS-Linux to 2.6 (2.6.0-test9-bk22) comments
 welcome.
Date: Sun, 23 Nov 2003 14:13:54 +0100 (MET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.SOL.4.40.0311231347190.8212-100000@gervaise.enst.fr>
References: <20031122085557.GA2745@obroa-skai.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jamal <hadi@cyberus.ca>, <mpls-linux-general@lists.sourceforge.net>,
        "David S. Miller" <davem@redhat.com>, <netdev@oss.sgi.com>,
        <jleu@mindspring.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20031122085557.GA2745@obroa-skai.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 22 Nov 2003, Harald Welte wrote:

> now that is interesting.  I have a working patch for adding netfilter
> hooks to the old MPLS stack.  If your rewrite doesn't yet have some,
> I'll gladly add them.
>
> I also have a working implementation of the draft-ietf-mpls-lsp-ping-01
> based on the netfilter hooks for James Leu's MPLS implementation, btw.

Hi Harald,

Thanks for your anwser.

Some details:

* Jamal and Dave are working on something. As soon as they release the
code we can get a whole picture of the state of the project. I don't know
the extent of their rewrite. Maybe jamal and/or Dave can give us an
overview of their changes. We'll see.

* In the meantime, we are syncing efforts with James. Right know we have a
patch that applies to test9. It has mostly been a RFC (Rewrite, Format and
Comment). What I did was:
       - Format the existing code, add comments for each function, start
         documenting, clean up unneeded local variables, conform to C90
       - Rewrite the procfs implementation to use seq_files (I've tested a
         little and works)
       - Clean up the "tunnel" module.
it compiles, boots and the entries are created in /proc/net/mpls/*

* Your netfilter and LSP Ping impl. patch would be must welcome. IIRC
correctly, James was also working on netfilter (I haven't, so I CC'ed him
here). James, can you give us an overview of that?

* I'm waiting (should come in some days) for James to commit my latest
changes to the P4 repository.

* CVS and sourceforge releases are out of date. We have two
possibilities: either you set up a p4 client and wait for James commit, or
I can provide you with a unified diff for 2.6.0-test9 using my private
copy.

However, I would be glad to take a look at your patches, even if they
apply to the old code.

Best regards



// -------------------------------------------------------------------
// Ramon Casellas - GET/ENST/INFRES/RHD/A508 - casellas@infres.enst.fr
// 37/39 rue Dareau 75014 Paris   --    http://perso.enst.fr/~casellas
