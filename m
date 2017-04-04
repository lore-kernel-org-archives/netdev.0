From: Niklas Cassel <niklas.cassel@axis.com>
Subject: Re: [PATCH v2] selftests: add a generic testsuite for ethernet device
Date: Tue, 4 Apr 2017 16:43:19 +0200
Message-ID: <8f363cf9-1696-bab9-ab54-a003541e1409@axis.com>
References: <20170404133247.28725-1-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: Corentin Labbe <clabbe.montjoie@gmail.com>, <shuah@kernel.org>,
        <davem@davemloft.net>, <andrew@lunn.ch>,
        <linux-kselftest@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bastet.se.axis.com ([195.60.68.11]:39802 "EHLO
        bastet.se.axis.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753188AbdDDOnY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 10:43:24 -0400
In-Reply-To: <20170404133247.28725-1-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/04/2017 03:32 PM, Corentin Labbe wrote:
> This patch add a generic testsuite for testing ethernet network device driver.
> 
> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
> ---
> 
> Changes since v1:
> - Test for starting master interface
> - Changed printing format to "RESULT: $netdev: line"
> - Use "ip link" to get device list
> 
>  tools/testing/selftests/net/Makefile     |   2 +-
>  tools/testing/selftests/net/netdevice.sh | 200 +++++++++++++++++++++++++++++++
>  2 files changed, 201 insertions(+), 1 deletion(-)
>  create mode 100755 tools/testing/selftests/net/netdevice.sh
> 
(snip)

Good work!

I suggest adding a test for setting MTU as well.
It doesn't have to be added before merging, but it
would be great if it could be added in the near future.


Regards,
Niklas
