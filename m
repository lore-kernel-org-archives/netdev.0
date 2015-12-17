From: Bryce Cronkite-Ratcliff <brycecr@gmail.com>
Subject: Instantaneous Threshold ECN marking for DCTCP
Date: Thu, 17 Dec 2015 08:13:49 -0800
Message-ID: <CADn3pMdDr=MmTyeZJ0ofacy+gcTC2qKJpWxp9gdBCpr+cfJzHA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:37002 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756071AbbLQQNu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 11:13:50 -0500
Received: by mail-wm0-f48.google.com with SMTP id p187so28416641wmp.0
        for <netdev@vger.kernel.org>; Thu, 17 Dec 2015 08:13:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi there,

I am attempting to run some experiments with DCTCP using mininet (so
this is all user-level emulation -- my switch is a linux namespace
using OVS). My question is on how to apply DCTCP's AQM. DCTCP's AQM
just marks all packets with CE if they are received when the queue is
over a threshold value of K and otherwise does not mark CE. The DCTCP
papers I have seen suggest that RED can be used to achieve this: set
probability to 1, burst to 1, and min and max to the same value.

However, tc-red, in accordance with this paper, does not allow burst
to be significantly below the minimum threshold value, so I am unable
to set the parameters I would like -- in particular to set burst to 1
-- without monkey-patching tc.

Is there a way to achieve this simple threshold-ECN marking AQM with
tc, or another approach?

Thank you!
