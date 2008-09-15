From: "Laurent Chavey" <chavey@google.com>
Subject: autotest question
Date: Mon, 15 Sep 2008 13:37:23 -0700
Message-ID: <97949e3e0809151337r4dc69f8cydd92074bb10088d8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "Mandeep Singh Baines" <msb@google.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:24005 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752225AbYIOUh3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2008 16:37:29 -0400
Received: from zps75.corp.google.com (zps75.corp.google.com [172.25.146.75])
	by smtp-out.google.com with ESMTP id m8FKbO8l005085
	for <netdev@vger.kernel.org>; Mon, 15 Sep 2008 21:37:24 +0100
Received: from rv-out-0708.google.com (rvbk29.prod.google.com [10.140.87.29])
	by zps75.corp.google.com with ESMTP id m8FKaS4M018119
	for <netdev@vger.kernel.org>; Mon, 15 Sep 2008 13:37:23 -0700
Received: by rv-out-0708.google.com with SMTP id k29so2322735rvb.0
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2008 13:37:23 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

how many control file can we have per sub directories.
I would like to have a glag_test/ directory with multiple testes (lldp
test, af_pkt)
each tests are independent of each other and use to verify a CL.



example:
  /depot/autotest/client/site_tests/glag_tests
    control
    glag_lldp_test.py
    glag_afpacket_test.py
    glag_linkup_test.py

    etc...
