From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [Patch net-next 1/2] net: fix a compile error when CONFIG_NET_LL_RX_POLL
 is not set
Date: Thu, 01 Aug 2013 10:29:52 +0300
Message-ID: <51FA0E70.6080408@linux.intel.com>
References: <1375326625-21427-1-git-send-email-amwang@redhat.com> <20130801.001803.72283212544630263.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-7
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: amwang@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:6748 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751551Ab3HAH3z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Aug 2013 03:29:55 -0400
In-Reply-To: <20130801.001803.72283212544630263.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/08/2013 10:18, David Miller wrote:
>> net/socket.c: In function =A1sock_poll=A2:
>> net/socket.c:1165:4: error: implicit declaration of function =A1sk_b=
usy_loop=A2 [-Werror=3Dimplicit-function-declaration]
>>
>> Fix this by adding a nop when !CONFIG_NET_LL_RX_POLL.
>>
>> Cc: Eliezer Tamir <eliezer.tamir@linux.intel.com>
>> Cc: David S. Miller <davem@davemloft.net>
>> Signed-off-by: Cong Wang <amwang@redhat.com>
>=20
> Is this really a net-next specific problem?  Doesn't it happen in
> 'net' too?
>=20
> If so, it should be fixed in 'net', not just 'net-next'.

Both issues are present in net.
And since these are bug fixes, IMHO both patches should go to net.
