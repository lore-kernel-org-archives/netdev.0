From: "Michael Bommarito" <mjbommar@umich.edu>
Subject: [PATCH 2.6.19-git19] BUG due to bad argument to ieee80211softmac_assoc_work
Date: Wed, 13 Dec 2006 13:17:12 -0500
Message-ID: <5b8e20700612131017n1cd8aff3qbe41351435427e25@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.241]:21290 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751607AbWLMSRO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Dec 2006 13:17:14 -0500
Received: by an-out-0708.google.com with SMTP id b33so78977ana
        for <netdev@vger.kernel.org>; Wed, 13 Dec 2006 10:17:13 -0800 (PST)
To: linux-kernel@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This didn't get much attention on bugzilla and I figured it was
important enough to forward along to the whole list since it's been
lingering around in ieee80211-softmac since 19-git5 at least.
http://bugzilla.kernel.org/show_bug.cgi?id=7657

Somebody was passing the whole mac device structure to
ieee80211softmac_assoc_work instead of just the assocation work, which
lead to much death and locking.

Attached is a patch that fixes this (the actual change is two lines
but context provided in patch for review).  The dmesg containing call
trace is attached to the bugzilla entry above.

-Mike
