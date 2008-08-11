From: "Parag Warudkar" <parag.warudkar@gmail.com>
Subject: Re: [Bugme-new] [Bug 11297] New: OOPS in rt6_fill_node
Date: Sun, 10 Aug 2008 21:05:07 -0400
Message-ID: <82e4877d0808101805t55a6ec5ft6c9b171ac1c7c3ab@mail.gmail.com>
References: <bug-11297-10286@http.bugzilla.kernel.org/>
	 <20080809213101.0927a808.akpm@linux-foundation.org>
	 <489F8827.4030904@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: "Brian Haley" <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.234]:10888 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753134AbYHKBFI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Aug 2008 21:05:08 -0400
Received: by wx-out-0506.google.com with SMTP id h29so1101733wxd.4
        for <netdev@vger.kernel.org>; Sun, 10 Aug 2008 18:05:08 -0700 (PDT)
In-Reply-To: <489F8827.4030904@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 10, 2008 at 8:30 PM, Brian Haley <brian.haley@hp.com> wrote:

> John sent me email off-line saying the patch fixed the problem, but he'd do
> more testing over the weekend.

I did test the patch and it now spits out "EOF on netlink" like
mentioned in bugzilla, which is not consistent with earlier behavior
which was to output -
unreachable fec0::1 dev lo  table unspec  proto none  src ::1  metric
-1  error -101 hoplimit 255 .

Parag
