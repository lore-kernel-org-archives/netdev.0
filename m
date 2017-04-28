From: carl h <heyen2000@gmail.com>
Subject: How does vlan driver pass vlan info to the h/w ethernet driver
Date: Fri, 28 Apr 2017 09:46:24 -0400
Message-ID: <CABM+yxkwQ1Oiw9p0tehLYyNgh6Qj=+1KKNk4hy35vz00DveyGA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f43.google.com ([209.85.215.43]:33834 "EHLO
        mail-lf0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1424154AbdD1Nq0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 09:46:26 -0400
Received: by mail-lf0-f43.google.com with SMTP id t144so34305688lff.1
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2017 06:46:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Desperately need info on this.

I'm trying to implement vlans on a target programmatically.

But first I wanted to set up vlans manually to help get a better
understanding of vlan setup. So I setup a vlan manually on my
development system (ubuntu) using the vconfig/ifconfig command
combination, but using the same command combination on the intended
target doesn't work.

Both systems use the same 8021q driver so the method of informing the
lower level Ethernet driver of the vlan info should be the same (I
would think). After looking at the vlan driver source it appears that
it collects the vlan info and adds the info the sk_buff structure
which is eventually passed to the ethernet driver, but it's not
obvious where the vlan magic is suppose to happen (ethernet driver or
8021q driver).

I looked at the source for the target system=E2=80=99s ethernet driver and =
it
supports an ioctl method of setting up a vlan. But this does not seem
like the conventional way that Linux sets up a vlan in the ethernet
driver.

By what mechanism does the vlan driver (8021q.ko) tell the Ethernet
hardware about a vlan?

Is it a special api call to the ethernet driver to set up a vlan in
hardware, or should the vlan driver be adding the vlan tags to the
packet?

Any info on vlan implementation would also be helpful too.
