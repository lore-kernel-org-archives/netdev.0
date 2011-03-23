From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-2.6] bonding: fix rx_handler locking
Date: Tue, 22 Mar 2011 19:16:43 -0700 (PDT)
Message-ID: <20110322.191643.115948014.davem@davemloft.net>
References: <1300797492-16128-1-git-send-email-jpirko@redhat.com>
	<4D8955CE.7040808@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jpirko@redhat.com, netdev@vger.kernel.org,
	nicolas.2p.debian@gmail.com, andy@greyhouse.net, fubar@us.ibm.com
To: panweiping3@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43448
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751774Ab1CWCQH convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Mar 2011 22:16:07 -0400
In-Reply-To: <4D8955CE.7040808@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Weiping Pan <panweiping3@gmail.com>
Date: Wed, 23 Mar 2011 10:07:10 +0800

> On 03/22/2011 08:38 PM, Jiri Pirko wrote:
>> This prevents possible race between bond_enslave and bond_handle_fra=
me
>> as reported by Nicolas by moving rx_handler register/unregister.
>> slave->bond is added to hold pointer to master bonding sructure. Tha=
t
>> way dev->master is no longer used in bond_handler_frame.
>> Also, this removes "BUG: scheduling while atomic" message
>>
>> Reported-by: Nicolas de Peslo=FCan<nicolas.2p.debian@gmail.com>
>> Signed-off-by: Jiri Pirko<jpirko@redhat.com>
 ...
> I test this patch with VirtualBox, no kernel panic occurs.

Thanks a lot Weiping.

Once I have test confirmwation from Nicolas I will apply this patch.
