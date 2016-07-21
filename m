From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 1/9] mlxsw: pci: Add resources query
 implementation.
Date: Thu, 21 Jul 2016 11:43:15 +0200
Message-ID: <20160721094315.GD2171@nanopsycho.orion>
References: <1469089160-4239-1-git-send-email-jiri@resnulli.us>
 <1469089160-4239-2-git-send-email-jiri@resnulli.us>
 <a126bf4d-2347-6b67-6cc7-99184aca55b9@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, yotamg@mellanox.com,
	eladr@mellanox.com, idosch@mellanox.com, nogahf@mellanox.com,
	ogerlitz@mellanox.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:35357 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751028AbcGUJnS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2016 05:43:18 -0400
Received: by mail-wm0-f50.google.com with SMTP id f65so15820942wmi.0
        for <netdev@vger.kernel.org>; Thu, 21 Jul 2016 02:43:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <a126bf4d-2347-6b67-6cc7-99184aca55b9@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Jul 21, 2016 at 11:41:18AM CEST, jhs@mojatatu.com wrote:
>
>Ok, here's an example:
>
>On 16-07-21 04:19 AM, Jiri Pirko wrote:
>>From: Nogah Frankel <nogahf@mellanox.com>
>>
>>
>>+static int
>>+mlxsw_pci_resources_query(struct mlxsw_pci *mlxsw_pci, char *mbox,
>>+			  struct mlxsw_resources *resources, u8 query_enabled)
>>+{
>
>to:
>
>static int mlxsw_pci_resources_query(struct mlxsw_pci *mlxsw_pci, char *mbox,
>                                     struct mlxsw_resources *resources,
>                                     u8 query_enabled)
>{
>
>Email is splitting that first line - but it is 80 chars or less


You are right. Will fix this.

>
>cheers,
>jamal
>
