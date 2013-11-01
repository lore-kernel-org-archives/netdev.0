From: walter harms <wharms@bfs.de>
Subject: Re: [patch -next] bonding: bond_get_size() returns wrong size
Date: Fri, 01 Nov 2013 13:30:58 +0100
Message-ID: <52739F02.80900@bfs.de>
References: <20131101101844.GA29795@longonot.mountain> <20131101104100.GU692@redhat.com> <20131101113558.GA3106@minipsycho.orion> <52739DAC.4000309@redhat.com>
Reply-To: wharms@bfs.de
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>,
	Veaceslav Falico <vfalico@redhat.com>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx01-fr.bfs.de ([193.174.231.67]:44513 "EHLO mx01-fr.bfs.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752336Ab3KAMbF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Nov 2013 08:31:05 -0400
In-Reply-To: <52739DAC.4000309@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Am 01.11.2013 13:25, schrieb Nikolay Aleksandrov:
> On 11/01/2013 12:35 PM, Jiri Pirko wrote:
>> Fri, Nov 01, 2013 at 11:41:00AM CET, vfalico@redhat.com wrote:
>>> On Fri, Nov 01, 2013 at 01:18:44PM +0300, Dan Carpenter wrote:
>>>> There is an extra semi-colon so bond_get_size() doesn't return the
>>>> correct value.
>>>>
>>>> Fixes: ec76aa49855f ('bonding: add Netlink support active_slave option')
>>>> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>>>
>>> Hrm, how does it even build. Good catch, thanks.
>>
>> I wonder about the same thing.
>>
> + and - can be unary operators so it's a valid expression :-)
> Nice catch
> 

NTL my gcc warns (-Wall)
  warning: statement with no effect

this should come up.

re,
 wh

> Nik
> 
> --
> To unsubscribe from this list: send the line "unsubscribe kernel-janitors" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
