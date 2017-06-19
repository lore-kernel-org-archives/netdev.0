From: =?UTF-8?Q?Lars_Erik_Storbuk=C3=A5s?= <storbukas.dev@gmail.com>
Subject: TCP Vegas per-socket alpha, beta, gamma parameters
Date: Mon, 19 Jun 2017 14:48:06 +0100
Message-ID: <CAF0XkCCmL4nxQbvGOVneRqh_9bofc+yFe=nrJAQzGv+nHmEWvg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f42.google.com ([209.85.214.42]:36259 "EHLO
        mail-it0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750757AbdFSNsI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2017 09:48:08 -0400
Received: by mail-it0-f42.google.com with SMTP id m47so66712793iti.1
        for <netdev@vger.kernel.org>; Mon, 19 Jun 2017 06:48:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm looking into how I can modify alpha, beta and gamma parameters for
TCP Vegas on a per-socket basis (if at all possible). I want to modify
the sending rate per-socket dynamically  (not system wide) when a
delay-based algorithm is used.

Is it possible to modify the parameters of Vegas without modifying the
source code of Vegas itself?

Would setting the (system wide) alpha, beta and gamma parameters be
updated immediately? Would an ongoing transmission get the new values
of alpha, beta or gamma when they are modified, or is it read only
when initialising a Vegas transmission?

Background for question:
I'm working on the implementation of a Deadline Aware, Less than Best
Effort. A framework for adding both LBE behaviour and awareness of
=E2=80=9Csoft=E2=80=9D delivery deadlines to any congestion control (CC) al=
gorithm,
whether loss-based, delay- based or explicit signaling-based. This
effectively allows it to turn an arbitrary CC protocol into a
scavenger protocol that dynamically adapts its sending rate to network
conditions and remaining time before the deadline, to balance
timeliness and transmission aggressiveness.

/ Lars Erik Storbuk=C3=A5s (storbukas.dev@gmail.com)
