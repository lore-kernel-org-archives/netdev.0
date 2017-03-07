From: tndave <tushar.n.dave@oracle.com>
Subject: Question on ixgbe flow director
Date: Tue, 7 Mar 2017 15:43:16 -0800
Message-ID: <c5c170c0-a024-5cb2-cd39-81b8cfffd8e5@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: intel-wired-lan <intel-wired-lan@lists.osuosl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1050.oracle.com ([141.146.126.70]:26254 "EHLO
        aserp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933453AbdCHBVY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Mar 2017 20:21:24 -0500
Received: from aserp1040.oracle.com (aserp1040.oracle.com [141.146.126.69])
        by aserp1050.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id v27NjnHl032225
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
        for <netdev@vger.kernel.org>; Tue, 7 Mar 2017 23:45:50 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have few questions regarding ixgbe flow director.
As per my understanding flow director in ixgbe can work in 2 exclusive ways,
a. Using ATR filters - where flow director is setup in HW by driver
identifying transmit traffic. And based on that, receive traffic of the
same flow get assigned/directed to same queue.

b. Perfect filter, where user can manually program flow director using
ethtool so that receive packets gets directed to specified rx queue
(depending on on how ethtool flow-type and action etc,.); But with
perfect filters there is no intelligence involved alike ATR has on
identifying transit, right?

Few question regarding ixgbe ATR,
1. does ATR works in case if protocol is UDP? (Based on the current
ixgbe_atr() it only supports TCP)
2. Does ATR flow director can be programmed using ethtool?
(As per my understanding only perfect filter can be programmed from
ethtool, is that so?)

Thanks in advance,
-Tushar
