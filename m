From: Vincent Bernat <bernat@luffy.cx>
Subject: Re: [PATCH v5 0/6] Add eBPF hooks for cgroups
Date: Thu, 15 Sep 2016 08:36:40 +0200
Message-ID: <m3y42tlldz.fsf@neo.luffy.cx>
References: <1473696735-11269-1-git-send-email-daniel@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: htejun@fb.com, daniel@iogearbox.net, ast@fb.com,
        davem@davemloft.net, kafai@fb.com, fw@strlen.de,
        pablo@netfilter.org, harald@redhat.com, netdev@vger.kernel.org,
        sargun@sargun.me, cgroups@vger.kernel.org
To: Daniel Mack <daniel@zonque.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bart.luffy.cx ([78.47.78.131]:34504 "EHLO bart.luffy.cx"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755583AbcIOGhJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Sep 2016 02:37:09 -0400
In-Reply-To: <1473696735-11269-1-git-send-email-daniel@zonque.org> (Daniel
        Mack's message of "Mon, 12 Sep 2016 18:12:09 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 =E2=9D=A6 12 septembre 2016 18:12 CEST, Daniel Mack <daniel@zonque.org>=C2=
=A0:

> * The sample program learned to support both ingress and egress, and
>   can now optionally make the eBPF program drop packets by making it
>   return 0.

Ability to lock the eBPF program to avoid modification from a later
program or in a subcgroup would be pretty interesting from a security
perspective.
--=20
Use recursive procedures for recursively-defined data structures.
            - The Elements of Programming Style (Kernighan & Plauger)
