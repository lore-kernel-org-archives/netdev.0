From: Veaceslav Falico <vfalico@gmail.com>
Subject: Re: [PATCH net-next] bonding: use kobject_put instead of _del after
 kobject_add
Date: Thu, 31 Jul 2014 12:46:01 +0200
Message-ID: <20140731104601.GA4373@mikrodark.usersys.redhat.com>
References: <1406633263-2115-1-git-send-email-vfalico@gmail.com>
 <20140730.173743.1842150455499005693.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, andy@greyhouse.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:52347 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932225AbaGaKtD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2014 06:49:03 -0400
Received: by mail-wg0-f50.google.com with SMTP id n12so2507960wgh.21
        for <netdev@vger.kernel.org>; Thu, 31 Jul 2014 03:49:00 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140730.173743.1842150455499005693.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 30, 2014 at 05:37:43PM -0700, David Miller wrote:
>From: Veaceslav Falico <vfalico@gmail.com>
>Date: Tue, 29 Jul 2014 13:27:43 +0200
>
>> Otherwise the name of the kobject isn't getting freed and other stuff from
>> kobject_cleanup() isn't getting called. kobject_put() will call
>> kobject_del() on its own in kobject_cleanup().
>>
>> CC: Jay Vosburgh <j.vosburgh@gmail.com>
>> CC: Andy Gospodarek <andy@greyhouse.net>
>> Signed-off-by: Veaceslav Falico <vfalico@gmail.com>
>
>Introduced in v3.14, so maybe steer this to 'net' instead?

Good idea. Should I re-send it or can you just apply it to net?
