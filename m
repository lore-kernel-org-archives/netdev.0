From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH net-next] net: em_canid: remove useless statements from
 em_canid_change
Date: Sun, 22 Jun 2014 18:27:34 +0200
Message-ID: <53A703F6.9090507@hartkopp.net>
References: <53A15267.7050304@cn.fujitsu.com> <20140621.154036.2087202508923213287.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, duanj.fnst@cn.fujitsu.com,
	lisovy@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.217]:9589 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751501AbaFVQ1j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jun 2014 12:27:39 -0400
In-Reply-To: <20140621.154036.2087202508923213287.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is right for the first set of filters that is ever configured in
em_canid_change().

But what happens in an update case?
Does is turn the cm_old reference to a memory leak then?

Or do we always get a brand new "struct tcf_ematch *m" here??

Regards,
Oliver

On 22.06.2014 00:40, David Miller wrote:
> From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> Date: Wed, 18 Jun 2014 16:48:39 +0800
> 
>> tcf_ematch is allocated by kzalloc in function tcf_em_tree_validate(),
>> so cm_old is always NULL.
>>
>> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> 
> Applied, thanks.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
