From: Siva Mannem <siva.mannem.lnx@gmail.com>
Subject: Clarification regarding IFLA_BRPORT_LEARNING_SYNC and aging of fdb
 entries learnt via br_fdb_external_learn_add()
Date: Tue, 30 Dec 2014 23:50:21 +0530
Message-ID: <CA+CtxLSv6Hg9kOmavqQKs+7y8b8+TBdW1dYwb3ZsTMOh=Ow8Ew@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:47261 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751305AbaL3SUW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Dec 2014 13:20:22 -0500
Received: by mail-wi0-f179.google.com with SMTP id ex7so24507535wid.6
        for <netdev@vger.kernel.org>; Tue, 30 Dec 2014 10:20:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am trying to understand the ongoing switch device offload effort and
am following the discussions. I have a question regarding
IFLA_BRPORT_LEARNING_SYNC flag and how aging happens when this flag is
enabled on a port that is attached to a bridge that has vlan filtering
enabled.

If I understand correctly, when  IFLA_BRPORT_LEARNING_SYNC is set on a
bridge port, fdb entries that are learnt externally(may be learnt by
hardware and driver is notified) are synced to bridges fdb using
br_fdb_external_learn_add(). The fdb
entries(fdb->added_by_external_learn set to true) that are learnt via
this method are also deleted by the aging logic after the aging time
even though L2 data forwadring  happens in hardware. Is there a way
where aging can be disabled for these entries? and let the entries be
removed only via br_fdb_external_learn_delete()? or am I missing
something?

Regards,
Siva.
