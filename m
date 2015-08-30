From: Ido Barkan <ibarkan@redhat.com>
Subject: using iperf over a veth pair
Date: Sun, 30 Aug 2015 16:49:21 +0300
Message-ID: <CAFmWiaSu-Foij1EGm5kby7gjDd2qeaR5Fo1oAVus2GRmkEar7w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:33564 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753153AbbH3NtX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2015 09:49:23 -0400
Received: by wicpl12 with SMTP id pl12so8376002wic.0
        for <netdev@vger.kernel.org>; Sun, 30 Aug 2015 06:49:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi everyone,
I am trying to use iperf over a veth pair. while iperf is pleased (it
reports a  suspicious very high bandwidth), according to tcpdump, no
traffic is going via the veth pair.

Also 'ping -I' refuses to send a ping via my veth ('destination is
unreachable' iirc).

/sys/class/net../statistics also shows no high counters.

Also, even when connecting to veth pairs to a Linux bridge and running
iperf 'via the bridge', tcpdump on the bridge yields nothing.
an important thing to noe here is that iperf api only accepts ip
addresses, not interfaces.
Routing ruls seems right, as they are automatically being created upon
assigning ip addresses to the veth pair ends.

Does the kernel short-circuits traffic here? How can I Tell it to pass
traffic via my virtual devices?

--
Thanks,
Ido Barkan
