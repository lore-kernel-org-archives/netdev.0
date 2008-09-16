From: Paul Moore <paul.moore@hp.com>
Subject: [RFC PATCH v6 00/16] Labeled networking patches for 2.6.28
Date: Tue, 16 Sep 2008 08:55:48 -0400
Message-ID: <20080916124722.17132.38741.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: selinux@tycho.nsa.gov, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Another revision to the patchset to fix two issues, one trivial, the other
not so much.  The trivial fix was to add some locking around the connection
labeling operations, we're messing with the socket so we should make sure
we lock it like we do everywhere else.  The second fix was to ensure that
we sync up a stream socket's MSS value when we add IP options to the socket.
We were doing everything correctly on the client side, but the server side
was a bit of a mess; I'm pretty happy with this fix as I think it actually
makes the code a bit cleaner in some respects and I believe actually shrinks
the size of the diff slightly (a good sign).

A special thanks to Joe Nall and John Wiseman for helping debug the MSS
problem.

I've updated both the git trees earlier today so hopefully the next cut of
the linux-next tree should have the latest bits.

 * git://git.infradead.org/users/pcmoore/lblnet-2.6_testing

--
paul moore
linux @ hp
