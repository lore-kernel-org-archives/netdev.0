From: Ashutosh Tripathi <azbycs@gmail.com>
Subject: Setting up interfaces in loopback mode using SIOCETHTOOL
Date: Tue, 16 Jun 2015 16:22:12 +0530
Message-ID: <CAC4WbQYt6K8xoHxviiGSsPRoEd7UX4Rhs0wkUvF+MPHG3yU2Aw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f171.google.com ([209.85.160.171]:33202 "EHLO
	mail-yk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754519AbbFPKwd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2015 06:52:33 -0400
Received: by ykfr66 with SMTP id r66so9985445ykf.0
        for <netdev@vger.kernel.org>; Tue, 16 Jun 2015 03:52:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

In spite of several days of trying to get information out of ethtool
source code, I could not get a way to set the loopback mode for
network interfaces. I was also referring to the driver code for ixgbe
devices to get more info on the support it provides to ethtool. In the
driver code, there seems to be a way to set the loopback mode. But I
had no idea how to refer to this code from user space.

The SIOCETHTOOL is pretty general purpose. There is a way to test the
interface in loopback mode via the command line interface. But I just
wanted to set the interface in loopback mode so that I could send
packets on the interface myself and stress the interface.

Please help me with any suggestion in this regard.

Thanks,
----
Ashutosh
