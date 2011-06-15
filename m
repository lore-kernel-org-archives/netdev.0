From: Bart Van Assche <bvanassche@acm.org>
Subject: Re: software iwarp stack update
Date: Wed, 15 Jun 2011 18:32:36 +0200
Message-ID: <BANLkTimmxN71ihGGXPH3JB1vGWyv1p-7mw@mail.gmail.com>
References: <BANLkTikUWpf4iAQT-9DwL_qSCEcY7CPN6w@mail.gmail.com> <OFC721DC15.CBE893E3-ONC12578B0.0053737C-C12578B0.00565784@ch.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-rdma@vger.kernel.org, linux-rdma-owner@vger.kernel.org,
	netdev@vger.kernel.org
To: Bernard Metzler <BMT@zurich.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:60527 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754357Ab1FOQd6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2011 12:33:58 -0400
In-Reply-To: <OFC721DC15.CBE893E3-ONC12578B0.0053737C-C12578B0.00565784@ch.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 15, 2011 at 5:43 PM, Bernard Metzler <BMT@zurich.ibm.com> w=
rote:
> after rebasing to davem/net-next-2.6.git, I formatted a patch adding
> to the initial 'siw' driver posting from last October. Given the rath=
er
> substantial amount of changes and time elapsed, I am not sure if peop=
le
> would better like a complete re-posting of all files.
> If I don't hear objection before tomorrow I would post it as an
> increment - as summarized below.

IMHO reposting the entire driver makes reviewing easier.

And please address checkpatch and sparse complaints before reposting.
The code currently available at gitorious triggers several easy to
address checkpatch and spare complaints:
$ cd softiwarp
$ convert-file-to-patch *[ch] |
/usr/src/torvalds-2.6.git/scripts/checkpatch.pl - -notree -nosignoff |
grep -E '^ERROR|^WARNING' | grep -v LINUX_VERSION_CODE | sort | uniq
-c | sort -rn
=A0=A0=A0=A0 10 ERROR: spaces required around that '?' (ctx:VxV)
=A0=A0=A0=A0=A0 8 ERROR: spaces required around that ':' (ctx:VxV)
=A0=A0=A0=A0=A0 3 ERROR: spaces required around that ':' (ctx:VxW)
=A0=A0=A0=A0=A0 2 ERROR: Macros with complex values should be enclosed =
in parenthesis
=A0=A0=A0=A0=A0 1 WARNING: line over 80 characters
=A0=A0=A0=A0=A0 1 ERROR: trailing whitespace
$ LC_ALL=3DC make C=3D2 | grep warning
/home/bart/software/softiwarp/softiwarp/siw_main.c:73:10: warning:
symbol 'siw_num_cep' was not declared. Should it be static?
/home/bart/software/softiwarp/softiwarp/siw_verbs.c:1417:14: warning:
symbol 'siw_reg_phys_mr' was not declared. Should it be static?
/home/bart/software/softiwarp/softiwarp/siw_mem.c:164:27: warning:
symbol 'siw_dma_mapping_ops' was not declared. Should it be static?

Bart.
