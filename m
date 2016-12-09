From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Synopsys Ethernet QoS
Date: Fri, 9 Dec 2016 11:29:02 +0000
Message-ID: <2df7a6dd-1128-d1d6-bf61-891f76cf7200@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        <lars.persson@axis.com>, <rabin.vincent@axis.com>,
        <netdev@vger.kernel.org>, <andy.shevchenko@gmail.com>,
        <CARLOS.PALMINHA@synopsys.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay.synopsys.com ([198.182.47.9]:33320 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751599AbcLIL3J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2016 06:29:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear David Miller,

These past 2 weeks we have been discussing the right way to go in terms of
Synopsys QoS support in the kernel.

The approach that raised more supporters was:

a) Test /stmicro/stmmac driver in a reference hardware prototyping platform (QoS
IPK) [Status: In Progress | 90% finished]

b) Merge the necessary features from AXIS’ synopsys based qos driver to the
/stmicro/stmmac
[Status: In Queue]

c) Rename /stmicro/stmmac driver to synopsys/ and re-factor the driver if necessary
[Status: In Queue]

d) Add QoS features incrementally to the new synopsys/ driver
[Status: In Queue]

This approach has the green light from AXIS and STMicro maintainers (Lars and
Peppe).

I would like to know if you support this plan.

Best Regards,
Joao
