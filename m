From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 88871] New: SO_BINDTODEVICE set sock's sk_bound_dev_if
 ,but interface's index can chang where interface down and up
Date: Tue, 25 Nov 2014 07:43:38 -0800
Message-ID: <20141125074338.7476ad08@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:62632 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750780AbaKYPnt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 10:43:49 -0500
Received: by mail-pa0-f43.google.com with SMTP id kx10so821645pab.2
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 07:43:48 -0800 (PST)
Received: from urahara (static-50-53-82-155.bvtn.or.frontiernet.net. [50.53.82.155])
        by mx.google.com with ESMTPSA id r3sm1839667pds.57.2014.11.25.07.43.46
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Nov 2014 07:43:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is not really a bug.

Begin forwarded message:

Date: Mon, 24 Nov 2014 22:50:49 -0800
=46rom: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla=
=2Ekernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 88871] New: SO_BINDTODEVICE set sock's sk_bound_dev_if ,b=
ut interface's index can chang where interface down and up


https://bugzilla.kernel.org/show_bug.cgi?id=3D88871

            Bug ID: 88871
           Summary: SO_BINDTODEVICE set sock's sk_bound_dev_if ,but
                    interface's index can chang where interface down an=
d
                    up
           Product: Networking
           Version: 2.5
    Kernel Version: 3.4
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: high
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: 10142904@qq.com
        Regression: No

call setsockopt(fd, SOL_SOCKET, SO_BINDTODEVICE, iface_brlan, iface_len=
 + 1),
the sock's sk_bound_dev_if be set to iface_brlan's index, when i pull o=
ut other
cab and plug in=EF=BC=8C  the br-lan's index can changed, the tcp packe=
t to the socket
be rest, because the orignal sk_bound_dev_if not match current br-lan's=
 index

--=20
You are receiving this mail because:
You are the assignee for the bug.
