From: Neal Cardwell <ncardwell@google.com>
Subject: Re: Slow ramp-up for single-stream TCP throughput on 4.2 kernel.
Date: Sat, 3 Oct 2015 12:29:36 -0400
Message-ID: <CADVnQym4U_dVVRdOVhORvVabwFjSHTQJ_LbbbYtzWVu0=mAp_A@mail.gmail.com>
References: <560F1672.5000602@candelatech.com>
	<560F1F74.9010207@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	ath10k <ath10k@lists.infradead.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:34951 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752047AbbJCQ3g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Oct 2015 12:29:36 -0400
Received: by obbzf10 with SMTP id zf10so102453930obb.2
        for <netdev@vger.kernel.org>; Sat, 03 Oct 2015 09:29:36 -0700 (PDT)
In-Reply-To: <560F1F74.9010207@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 2, 2015 at 8:21 PM, Ben Greear <greearb@candelatech.com> wrote:
> Gah, seems 'cubic' related.  That is the default tcp cong ctrl
> I was using (same in 3.17, for that matter).

There have been recent changes to CUBIC that may account for this. If
you could repeat your test with more instrumentation, eg "nstat", that
would be very helpful.

nstat > /dev/null
# run one test
nstat

Also, if you could take a sender-side tcpdump trace of the test, that
would be very useful (default capture length, grabbing just headers,
is fine).

Thanks!

neal
