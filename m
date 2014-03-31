From: Jay Vosburgh <j.vosburgh@gmail.com>
Subject: Re: [PATCH 3/5] bonding: Initialize the ALB work queue for lb mode only.
Date: Mon, 31 Mar 2014 09:27:21 -0700
Message-ID: <5848.1396283241@famine>
References: <1396070946-17650-1-git-send-email-maheshb@google.com> <1396280940.29410.38.camel@edumazet-glaptop2.roam.corp.google.com>
Cc: Mahesh Bandewar <maheshb@google.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:41157 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752747AbaCaQ1X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 12:27:23 -0400
Received: by mail-pa0-f49.google.com with SMTP id lj1so8404728pab.22
        for <netdev@vger.kernel.org>; Mon, 31 Mar 2014 09:27:23 -0700 (PDT)
In-reply-to: <1396280940.29410.38.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:

>On Fri, 2014-03-28 at 22:29 -0700, Mahesh Bandewar wrote:
>> micro change to initialize / cancel the ALB work queue only
>> if the mode selected is ALB or TLB.
>> 
>> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
>> ---
>
>Can the mode of a bonding device be dynamically changed ?

	No.  The mode can only be changed when there are no slaves in
the bond, and the bond is administratively down.

	-J

---
	-Jay Vosburgh, j.vosburgh@gmail.com
