From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next v2 2/3] bonding: support QinQ for bond arp
 interval
Date: Wed, 19 Mar 2014 06:39:58 +0100
Message-ID: <20140319053958.GA1242@redhat.com>
References: <1395139433-19576-1-git-send-email-dingtianhong@huawei.com>
 <1395139433-19576-3-git-send-email-dingtianhong@huawei.com>
 <20140318120558.GA6430@redhat.com>
 <7072.1395165598@death.nxdomain>
 <20140318192742.GB6430@redhat.com>
 <5328F2F5.6010304@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Jay Vosburgh <fubar@us.ibm.com>, andy@greyhouse.net,
	kaber@trash.net, davem@davemloft.net, netdev@vger.kernel.org
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41618 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752145AbaCSGMz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Mar 2014 02:12:55 -0400
Content-Disposition: inline
In-Reply-To: <5328F2F5.6010304@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 19, 2014 at 09:29:25AM +0800, Ding Tianhong wrote:
...snip...
>The QinQ didn't mean that the first(outer) tag must be 802.1ad, and the second(inner) tag must be 802.1q,

Do you have a quote for that from the standard? What I know and read
everywhere is that the standard specifies the outer s-tag to always be
0x88A8.

The other thing is that we don't live in an ideal world and there are a
lot of non-standard implementations out there, which might use 0x8100,
0x9100, 0x9200, 0x9300... for the outer s-tag, that's why using the
user-provided proto is better.
