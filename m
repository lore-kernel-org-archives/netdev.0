From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [PATCH 1/2] 8139too: clean up spaces and TABs
Date: Mon, 16 Jun 2008 17:07:38 +0200
Message-ID: <485681BA.4060808@s5r6.in-berlin.de>
References: <4853BB62.1060109@freemail.hu> <4853C8AD.9020407@s5r6.in-berlin.de> <48541165.7050304@freemail.hu> <485421C1.8010102@s5r6.in-berlin.de> <4854C9BF.8040900@freemail.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Newall <davidn@davidnewall.com>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	Trivial Patch Monkey <trivial@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: =?ISO-8859-1?Q?N=E9meth_M=E1rton?= <nm127@freemail.hu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755988AbYFPPJ5@vger.kernel.org>
In-Reply-To: <4854C9BF.8040900@freemail.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

N=E9meth M=E1rton wrote:
> I have chosen the checkpatch.pl's output to compare the
> whether the old and the new code are better or not. Maybe that was a =
mistake.

Well, running checkpatch on source files (rather than patches) and
fixing the files up according to checkpatch's output and own good
judgement has two uses:
  - bring new unmerged code into shape before submission,
  - bring older mainline code into the canonical form as a basis
    for further work.  You certainly saw how lots and lots of such
    checkpatch-assisted cleanups went into arch/x86.  That's because
    they were found useful for the work on unifying the two x86
    architecture subtrees.
So, a coding style rework has its use even on legacy code if people hav=
e
plans with the code.  But keep in mind that (a) the whitespace rules
aren't hard and universally agreed upon rules, (b) coding style has a
number of other aspects of arguably greater importance than whitespace
style, like proper modularization, good choices of names, use of common
idioms and APIs instead of own inventions, and so on.
--=20
Stefan Richter
-=3D=3D=3D=3D=3D-=3D=3D--- -=3D=3D- =3D----
http://arcgraph.de/sr/
