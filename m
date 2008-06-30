From: <samuel@sortiz.org>
Subject: Re: [PATCH] IRDA: Fix =?UTF-8?Q?genlmsg=5Fput=28=29=20return=20value=20ch?=
 =?UTF-8?Q?eck=2E?=
Date: Mon, 30 Jun 2008 09:11:20 +0200
Message-ID: <f37495acbb40afdbe5fb783282bd2b18@localhost>
References: <f4845fc0806231329p7ef94a8dqafe63feea89ad949@mail.gmail.com> <1214299754-27769-1-git-send-email-juliusv@google.com> <20080627.200133.71838192.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: juliusv@google.com, kaber@trash.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 25.mail-out.ovh.net ([91.121.27.228]:39538 "HELO
	25.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1757530AbYF3HLV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2008 03:11:21 -0400
In-Reply-To: <20080627.200133.71838192.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>






On Fri, 27 Jun 2008 20:01:33 -0700 (PDT), David Miller

<davem@davemloft.net> wrote:

> From: Julius Volz <juliusv@google.com>

> Date: Tue, 24 Jun 2008 11:29:14 +0200

> 

>> Fix an incorrect return value check of genlmsg_put() in

> irda_nl_get_mode().

>> genlmsg_put() does not use ERR_PTR() to encode return values, it just

>> returns NULL on error.

>>

>> Signed-off-by: Julius Volz <juliusv@google.com>

> 

> I'm assuming Samuel will grab this and send it to me in his

> next IRDA merge to me.

That's right. This should happen this week.



Cheers,

Samuel.

