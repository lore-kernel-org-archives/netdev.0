From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 8/12] net_device seq_file
Date: Thu, 18 Jan 2007 10:07:07 -0700
Message-ID: <m1ac0g6z7o.fsf@ebiederm.dsl.xmission.com>
References: <200701171851.14734.dim@openvz.org>
	<200701171911.53312.dim@openvz.org> <20070117123644.756aecc1@oldman>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dmitry Mishin <dim@openvz.org>, containers@lists.osdl.org,
	alexey@sw.ru, netdev@vger.kernel.org, saw@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:35513 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752074AbXARRIQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jan 2007 12:08:16 -0500
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20070117123644.756aecc1@oldman> (Stephen Hemminger's message of
	"Wed, 17 Jan 2007 12:36:44 -0800")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> writes:

> On Wed, 17 Jan 2007 19:11:52 +0300
> Dmitry Mishin <dim@openvz.org> wrote:
>
>> Library function to create a seq_file in proc filesystem,
>> showing some information for each netdevice.
>> This code is present in the kernel in about 10 instances, and
>> all of them can be converted to using introduced library function.
>> 
>> Signed-off-by: Andrey Savochkin <saw@swsoft.com>
>
> But the implementations can use static data rather than allocation,
> also the long term desire is to get rid of supporting most of these proc
> interfaces.

While we do have the interfaces we need to support them, and not
let them bit rot.

That said so long as we have to individually register and unregister
proc entries it is an active measure by the caller and they should
be able to handle allocation and freeing of data structures as well.

Eric
