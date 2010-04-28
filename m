From: Jiri Skala <jskala@redhat.com>
Subject: iputils flowlabel
Date: Wed, 28 Apr 2010 10:51:48 +0200
Message-ID: <1272444708.3035.39.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35022 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751826Ab0D1Ivu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Apr 2010 04:51:50 -0400
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o3S8pn4W007240
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 28 Apr 2010 04:51:50 -0400
Received: from [10.34.29.135] (dhcp-29-135.brq.redhat.com [10.34.29.135])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id o3S8pmCm017510
	for <netdev@vger.kernel.org>; Wed, 28 Apr 2010 04:51:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
I'd like to ask about current state of FLOWLABEL functionality. This is
currently wrapped into define and disabled by default.

Trying to enable it means to define (somehow = in proprietary header)
in6_flowlabel_req structure because usage of linux/in6.h conflicts with
glibc's headers.

Is flowlabel fnc inside ifdef due to described 'header' issue? Any other
comment to this topic?

Thanks

Jiri

