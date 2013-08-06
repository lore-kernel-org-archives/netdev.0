From: Kinley Dorji <kinleyd@gmail.com>
Subject: Bug: alx: Atheros AR8131/AR8151/AR8152/AR8161 Ethernet driver
Date: Tue, 6 Aug 2013 11:31:39 +0600
Message-ID: <CACtZaFJZCWigdT6_vsP9BTRSORzumu33xUtyPtpiDuNn3DQi+w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:65154 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752399Ab3HFFbl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 01:31:41 -0400
Received: by mail-wi0-f174.google.com with SMTP id j17so2239527wiw.7
        for <netdev@vger.kernel.org>; Mon, 05 Aug 2013 22:31:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'd like to report a bug that has been introduced since the mainlining
of the NIC drivers originally in the package AUR/dkms-alx pertaining
to the above mentioned network cards.

Kernels affected: 3.10.1 - 3.10.5
All worked well for kernels <= 3.9.9

Environment in which it occurs:

kernel: >= 3.10
conky: any version (gui/cli)
NIC: Any one of the above family

conky variables that probe the NIC all return nothing or 0: eg:
upspeed, upspeedgraph, downspeed, downspeedgraph

A small discussion on the issue:
https://bbs.archlinux.org/viewtopic.php?id=166555

Network connectivity itself is not a problem - connection works and is stable

Conky isn't the problem because it works in kernels <= 3.9.9 with dkms-alx.

Hope it can be resolved, at your convenience.

Thank you for the good work you do,

Kinley
