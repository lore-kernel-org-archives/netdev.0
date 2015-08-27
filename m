From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 2/3] mlxsw: expose EMAD transactions statistics
 via debugfs
Date: Thu, 27 Aug 2015 08:40:29 +0200
Message-ID: <20150827064029.GI2228@nanopsycho.orion>
References: <20150827054004.GA2228@nanopsycho.orion>
 <20150826.230115.2076911912997875741.davem@davemloft.net>
 <20150827062704.GE2228@nanopsycho.orion>
 <20150826.233603.681080899557993733.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sfeldma@gmail.com, netdev@vger.kernel.org, idosch@mellanox.com,
	eladr@mellanox.com, ogerlitz@mellanox.com, jiri@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:36946 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751285AbbH0Gkc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 02:40:32 -0400
Received: by widdq5 with SMTP id dq5so34675448wid.0
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2015 23:40:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150826.233603.681080899557993733.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Aug 27, 2015 at 08:36:03AM CEST, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Thu, 27 Aug 2015 08:27:04 +0200
>
>> I'm not saying it is not possible, it certainly is. But I think that
>> for example rocker internals have no value to default user, he
>> should not care and he cannot find out what is going on there
>> without knowledge or rocker.c code. The question is, do we need some
>> standard interface to expose random debugging data? I don't think
>> so, I think that debugfs is exactly the tool to be used in that
>> case.
>
>If it is only interesting to rocker.c maintainer, he can keep a local
>patch he applies when he needs such a facility.
>
>This discussion is becomming circular.
>
>If it's useful, it needs a well defined interface.
>
>If it's not useful, it doesn't belong in the tree.
>
>Therefore, debugfs is useless.

Fair enough.
