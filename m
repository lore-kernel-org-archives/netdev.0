From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC rocker-net-next 0/6] net: flow: Minor fixes and cleanups
Date: Mon,  5 Jan 2015 15:50:04 +0900
Message-ID: <1420440610-20621-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:49675 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751124AbbAEGuc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 01:50:32 -0500
Received: by mail-pd0-f181.google.com with SMTP id v10so27575148pde.12
        for <netdev@vger.kernel.org>; Sun, 04 Jan 2015 22:50:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi John,

This series contains several minor fixes and cleanups for your
consideration.

They apply on to of https://github.com/jrfastab/rocker-net-next
head commit 1b2a1e4 ("net: rocker: implement delete flow routine")

I have previously lightly exercised them on top of
https://github.com/jrfastab/flow-net-next
head commit 9f75688 ("net: flow: add new DYNAMIC flag")

Simon Horman (6):
  net: flow: Cancel innermost nested attribute first
  net: flow: Handle error when putting a field while putting a flow
  net: flow: Remove unnecessary zero-header check when putting a flow
  net: flow: free action args
  net: flow: Return more fine-grained error when handing flows commands
  net: flow: Limit checking of ndo_flow_{set,del}_flows

 net/core/flow_table.c | 47 ++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 36 insertions(+), 11 deletions(-)

-- 
2.1.3
