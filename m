From: ebiederm@xmission.com (Eric W. Biederman)
Subject: 2.6.38-rc3 regression ipv6 TFTP download with curl failing in getpeername?
Date: Tue, 08 Feb 2011 01:41:32 -0800
Message-ID: <m1ei7iamnn.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Does anyone have a clue what could be causing this?  It looks like
getpeername for ipv6 has changed in the tcp case did udp possibly get
missed?

Currently curl is failing for me like this.  When doing a tftp transfer
over ::1.

  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0  200M    0     0    0  570k      0  12.7M  0:00:15 --:--:--  0:00:15 12.7M
curl: (55) getpeername() failed with errno 107: Transport endpoint is not connected

Tomorrow I will dig deeper but for tonight I wanted to ask and see what
other people see.

Eric
