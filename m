From: Petri Gynther <petri.gynther@gmail.com>
Subject: How to hairpin two Ethernet interfaces together (L2 hub/repeater mode)?
Date: Fri, 22 Feb 2013 16:10:54 -0800
Message-ID: <CAKuTDr_eC4Wrv=uGthGJk3Zps=fnyAxpqqmsSDau7ZLs4PGyZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:57409 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755239Ab3BWAKz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2013 19:10:55 -0500
Received: by mail-ie0-f169.google.com with SMTP id 13so1452203iea.0
        for <netdev@vger.kernel.org>; Fri, 22 Feb 2013 16:10:54 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi netdev:

I'd like to hairpin two Ethernet interfaces together (e.g. eth0 and
eth1) so that any frame received on eth0 is forwarded as-is to eth1
and vice versa.

Does Linux networking code support this? I've looked at the bridging
code, but it doesn't seem to do this (at least trivially).
Specifically, when eth0 and eth1 are added to bridge, unicast frames
destined to eth0 (or eth1) MAC address end up to the bridge interface
for local consumption, rather than being flooded to other ports on the
bridge.

Any trivial solutions to this? Can Linux bridge be configured in L2
hub/repeater mode so that it simply floods every Rx frame to all other
ports of the bridge?
