From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [ANNOUNCE] iproute2 4.1.1
Date: Tue, 7 Jul 2015 11:14:46 -0700
Message-ID: <20150707111446.5505db4a@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:33891 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932391AbbGGSOh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2015 14:14:37 -0400
Received: by pdbep18 with SMTP id ep18so129959840pdb.1
        for <netdev@vger.kernel.org>; Tue, 07 Jul 2015 11:14:37 -0700 (PDT)
Received: from urahara (static-50-53-82-155.bvtn.or.frontiernet.net. [50.53.82.155])
        by mx.google.com with ESMTPSA id js8sm22573152pbb.9.2015.07.07.11.14.36
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jul 2015 11:14:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Maintenance release of iproute2 for Linux 4.1

This fixes issues affecting some environments with iproute2 4.1.
The MPLS support was missing one patch, and the introduction of
TIPC made build difficult in environments without proper libmnl.

Source:
  http://www.kernel.org/pub/linux/utils/net/iproute2/iproute2-4.1.1.tar=
=2Egz

Repository:
  git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git

Report problems (or enhancements) to the netdev@vger.kernel.org mailing=
 list.

---
Gustavo Zacarias (1):
      tipc: make build conditional on having libmnl

Jan Engelhardt (1):
      build: must honor pkg-config flags for libmnl

Michal Kube=C4=8Dek (1):
      include: add copy of tipc.h

Roopa Prabhu (1):
      mpls: always set type RTN_UNICAST and scope RT_SCOPE_UNIVERSE for

Stephen Hemminger (1):
      v4.1.1
