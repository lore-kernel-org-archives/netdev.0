From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH iproute2] tc/netem: loss gemodel options fixes
Date: Tue, 5 Aug 2014 10:09:17 +0200
Message-ID: <CAPh34meHr_7z4nznKBeKV6Y4Dypni72yM7bSOdkQ6hopsnjzGg@mail.gmail.com>
References: <29682.1399754098@localhost.localdomain>
	<CAPh34mf4ahPyTDf-tEhsNKSFBL6GYjES9+TTvDjhMf2YLTr04Q@mail.gmail.com>
	<11467.1400183199@localhost.localdomain>
	<20140804123709.502bbe1d@haswell.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jay Vosburgh <jay.vosburgh@canonical.com>,
	netdev <netdev@vger.kernel.org>, netem@lists.linux-foundation.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f177.google.com ([209.85.220.177]:47963 "EHLO
	mail-vc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932516AbaHEIJS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2014 04:09:18 -0400
Received: by mail-vc0-f177.google.com with SMTP id hy4so858761vcb.8
        for <netdev@vger.kernel.org>; Tue, 05 Aug 2014 01:09:17 -0700 (PDT)
In-Reply-To: <20140804123709.502bbe1d@haswell.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4 August 2014 21:37, Stephen Hemminger <stephen@networkplumber.org> wrote:

> I went ahead and applied these. They make sense and got no response.

Wait Stephen,

Jay do you compared your changes with the expected results? I mean did
you run tests that the Markov chain model is _now_  working correctly
(in all states)?

The setup will be easy: send 10000 packets, capture the packets and
'wc -l tcpdump -r trace.pcap' and compare to the expected number of
packets for a given markov state setup. Enough bugs here where the
should be no bugs at all. Some simple tests should be enough to get
rid of them.

Hagen
