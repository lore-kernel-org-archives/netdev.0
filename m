From: "Ray Lee" <ray-lk@madrabbit.org>
Subject: Re: questions on NAPI processing latency and dropped network packets
Date: Fri, 11 Jan 2008 21:37:18 -0800
Message-ID: <2c0942db0801112137k3f3f885ek212d5cbaecb7fea0@mail.gmail.com>
References: <478654C3.60806@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Chris Friesen" <cfriesen@nortel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:20477 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751478AbYALFhU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2008 00:37:20 -0500
Received: by fg-out-1718.google.com with SMTP id e21so1401069fga.17
        for <netdev@vger.kernel.org>; Fri, 11 Jan 2008 21:37:19 -0800 (PST)
In-Reply-To: <478654C3.60806@nortel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Jan 10, 2008 9:24 AM, Chris Friesen <cfriesen@nortel.com> wrote:
> After a recent userspace app change, we've started seeing packets being
> dropped by the ethernet hardware (e1000, NAPI is enabled).  The
> error/dropped/fifo counts are going up in ethtool:

(These are perhaps too obvious, but I didn't see the questions or
answers in the thread.)

Can you reproduce it with a simple userspace cpu hog? (Two, really,
one per cpu.)

Can you reproduce it with the newer e1000?

Can you reproduce it with git head?

If the answer to the first one is yes, the last no, then bisect until
you get a kernel that doesn't show the problem. Backport the fix,
unless the fix happens to be CFS. However, I suspect that your
userpace app is just starving the system from time to time.
