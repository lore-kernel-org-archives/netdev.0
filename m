From: Carol Soto <clsoto@linux.vnet.ibm.com>
Subject: Re: [PATCH v2] net/mlx4: Memcpy at slave_event should copy sizeof
 mlx4_eqe
Date: Mon, 26 Oct 2015 13:27:18 -0500
Message-ID: <562E7086.9000204@linux.vnet.ibm.com>
References: <1445872540-18605-1-git-send-email-clsoto@linux.vnet.ibm.com>
 <CAJ3xEMgFjen8EY6WX3Zpk1k4pAou=HF8ZZHVVnaUtwePAZrcUg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>, brking@linux.vnet.ibm.com,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e18.ny.us.ibm.com ([129.33.205.208]:42609 "EHLO
	e18.ny.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752862AbbJZS11 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 14:27:27 -0400
Received: from localhost
	by e18.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <clsoto@linux.vnet.ibm.com>;
	Mon, 26 Oct 2015 14:27:27 -0400
Received: from b01cxnp23034.gho.pok.ibm.com (b01cxnp23034.gho.pok.ibm.com [9.57.198.29])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id B262738C803B
	for <netdev@vger.kernel.org>; Mon, 26 Oct 2015 14:27:23 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by b01cxnp23034.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t9QIRNwJ065866
	for <netdev@vger.kernel.org>; Mon, 26 Oct 2015 18:27:23 GMT
Received: from d01av03.pok.ibm.com (localhost [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t9QIRMC2027481
	for <netdev@vger.kernel.org>; Mon, 26 Oct 2015 14:27:23 -0400
In-Reply-To: <CAJ3xEMgFjen8EY6WX3Zpk1k4pAou=HF8ZZHVVnaUtwePAZrcUg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 10/26/2015 12:02 PM, Or Gerlitz wrote:
> On Mon, Oct 26, 2015 at 5:15 PM,  <clsoto@linux.vnet.ibm.com> wrote:
>> From: Carol L Soto <clsoto@linux.vnet.ibm.com>
>>
>> If the caps.eqe_size is bigger than the struct mlx4_eqe then there
>> is a potential for corrupting data at the master context. We can see
>> the message "Master failed to generate an EQE for slave: X" when the
>> event_eqe array wraps and we can see potential oops at the function
>> mlx4_GEN_EQE. Also correct a memset of cmd_eqe to use the sizeof
>> mlx4_eqe instead of eqe_size.
>>
>> Fixes: 08ff32352d6f ('mlx4: 64-byte CQE/EQE support')
>> Signed-off-by: Carol L Soto <clsoto@linux.vnet.ibm.com>
> Thanks Carol, I'd like to review this a bit more tomorrow and will
> send it with another fix/es to net
Sure thanks.
