From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 195217] siocsifflags - irda doesn't work (MCS7780)
Date: Thu, 4 May 2017 09:48:13 -0700
Message-ID: <20170504094813.277fea05@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:32797 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752384AbdEDQsQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 12:48:16 -0400
Received: by mail-pg0-f46.google.com with SMTP id y4so11462596pge.0
        for <netdev@vger.kernel.org>; Thu, 04 May 2017 09:48:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Apparently IRDA is broken by VMAP_STACK

Begin forwarded message:

Date: Thu, 04 May 2017 12:16:15 +0000
From: bugzilla-daemon@bugzilla.kernel.org
To: stephen@networkplumber.org
Subject: [Bug 195217] siocsifflags - irda doesn't work (MCS7780)


https://bugzilla.kernel.org/show_bug.cgi?id=195217

Jerome (jb_69100@yahoo.com) changed:

           What    |Removed                     |Added
----------------------------------------------------------------------------
          Component|Other                       |USB
     Kernel Version|4.9.X, 4.10.X, 4.11-rcX     |4.9.0 --> 4.11.0
            Product|Networking                  |Drivers
           Severity|blocking                    |high

--- Comment #2 from Jerome (jb_69100@yahoo.com) ---
Hi,

If I compile the kernel by setting CONFIG_VMAP_STACK = N, "ifconfig irda0 up"
is working correctly. (Tested with kernel 4.11.0)

I suppose the problem comes either from the MCS7780 driver (use the stack not
"in the rules"?) Or from VMAP_STACK.

Can you help me better understand the problem?

Regards,
Jerome.

-- 
You are receiving this mail because:
You are the assignee for the bug.
