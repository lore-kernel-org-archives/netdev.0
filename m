From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [patch -next] bonding: bond_get_size() returns wrong size
Date: Fri, 01 Nov 2013 13:25:16 +0100
Message-ID: <52739DAC.4000309@redhat.com>
References: <20131101101844.GA29795@longonot.mountain> <20131101104100.GU692@redhat.com> <20131101113558.GA3106@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21524 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751949Ab3KAM2n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Nov 2013 08:28:43 -0400
In-Reply-To: <20131101113558.GA3106@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/01/2013 12:35 PM, Jiri Pirko wrote:
> Fri, Nov 01, 2013 at 11:41:00AM CET, vfalico@redhat.com wrote:
>> On Fri, Nov 01, 2013 at 01:18:44PM +0300, Dan Carpenter wrote:
>>> There is an extra semi-colon so bond_get_size() doesn't return the
>>> correct value.
>>>
>>> Fixes: ec76aa49855f ('bonding: add Netlink support active_slave option')
>>> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>>
>> Hrm, how does it even build. Good catch, thanks.
> 
> I wonder about the same thing.
> 
+ and - can be unary operators so it's a valid expression :-)
Nice catch

Nik
