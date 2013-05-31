From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net-next 0/6] net/core, bonding: dev_uc_sync fixes, bonding
 update
Date: Fri, 31 May 2013 12:01:45 -0400
Message-ID: <51A8C969.5090005@redhat.com>
References: <1369961744-21460-1-git-send-email-fubar@us.ibm.com> <20130531.013155.25881045915195152.davem@davemloft.net> <20130531152812.GB2910@sbohrermbp13-local.rgmadvisors.com> <26013.1370015790@death.nxdomain>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Shawn Bohrer <shawn.bohrer@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59310 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752843Ab3EaQCP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 May 2013 12:02:15 -0400
In-Reply-To: <26013.1370015790@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/31/2013 11:56 AM, Jay Vosburgh wrote:
> Shawn Bohrer <shawn.bohrer@gmail.com> wrote:
>
>> On Fri, May 31, 2013 at 01:31:55AM -0700, David Miller wrote:
>>> From: Jay Vosburgh <fubar@us.ibm.com>
>>> Date: Thu, 30 May 2013 17:55:38 -0700
>>>
>>>> 	This patch set includes 6 patches: four fixes to the dev_mc_sync /
>>>> dev_mc_unsync system; and two patches to bonding, one to utilize the sync
>>>> / unsync functions, and another minor fix related to MAC address handling.
>>>
>>> These look like fixes that should go into net, why target net-next?
>>
>> In my oppinion 0-4 should go into net since they fix the bug I
>> reported in:
>>
>> http://comments.gmane.org/gmane.linux.network/270477
>>
>> I've tested patches 0-4 of this series so feel free to add my tested
>> by to those:
>>
>> Tested-by: Shawn Bohrer <sbohrer@rgmadvisors.com>
>>
>>From just a casual observation of patch 5-6 they do not appear to be
>> bug fixes which is why this was probably marked net-next.
>
> 	They're against net-next because I was working to convert
> bonding to dev_sync/unsync against net-next and neglected to rebase then
> before I posted.  The bonding patches (5 and 6) do fix a couple of bugs
> related to MAC address handling on s390 (the lack of additional unicast
> address propagation to the slaves makes qeth unhappy in some cases), so
> arguably they could go either way, but I'm ok with those in net-next if
> it's an issue.
>
> 	I do agree that 1-4 should go into net, once Vlad gives them a
> look.
>
> 	-J

I've reviewed the patches and ran a quick test.  They look good and fix
obvious problems.  Thanks to Jay for finding and fixing them.

Reviewed-by: Vlad Yasevich <vyasevic@redhat.com>

-vlad

>
> ---
> 	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
>
