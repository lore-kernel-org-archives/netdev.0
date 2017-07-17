From: Rao Shoaib <rao.shoaib@oracle.com>
Subject: What is the correct behavior ipv4/ipv6
Date: Mon, 17 Jul 2017 11:28:02 -0700
Message-ID: <f7aa79a4-81d9-5b6d-3a27-0d681e5619ae@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:32912 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751311AbdGQS2E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 14:28:04 -0400
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
        by userp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id v6HIS31l000335
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
        for <netdev@vger.kernel.org>; Mon, 17 Jul 2017 18:28:03 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
        by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id v6HIS3rq028355
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
        for <netdev@vger.kernel.org>; Mon, 17 Jul 2017 18:28:03 GMT
Received: from abhmp0016.oracle.com (abhmp0016.oracle.com [141.146.116.22])
        by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id v6HIS39i015790
        for <netdev@vger.kernel.org>; Mon, 17 Jul 2017 18:28:03 GMT
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am looking at a system which is configured for IPv6 only but sits in a 
network that serves both IPv4 and IPv6. When an IPv4 packet with a 
destination  broadcast address is sent out (in this case DHCP) the 
system accepts it and since it does not have any route to the sender it 
prints the Martian message.

Sure, we can turn off the Martian message and maybe the system should be 
in an IPv6 only network.

The question that is being asked is that why is the system accepting an 
IPv4 broadcast packet in the first place ?  Is this behavior incorrect 
and should I submit a patch ?

Thanks,

Shoaib
