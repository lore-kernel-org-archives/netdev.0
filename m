From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next v3 0/4] mpls: Behaviour-changing improvements
Date: Wed, 01 Apr 2015 16:14:27 -0500
Message-ID: <877ftvv9e4.fsf@x220.int.ebiederm.org>
References: <1426866170-28739-1-git-send-email-rshearma@brocade.com>
	<1427739356-28113-1-git-send-email-rshearma@brocade.com>
	<20150401.153041.376950284605107486.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: rshearma@brocade.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:33457 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751746AbbDAVS0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 17:18:26 -0400
In-Reply-To: <20150401.153041.376950284605107486.davem@davemloft.net> (David
	Miller's message of "Wed, 01 Apr 2015 15:30:41 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: Robert Shearman <rshearma@brocade.com>
> Date: Mon, 30 Mar 2015 19:15:52 +0100
>
>> This series consists of several small changes to make it easier to
>> understand the code, along with security and RFC-compliance
>> changes. These are important to consider before userspace begins
>> relying on the previous behaviour.
>
> Robert, you _absolutely_ must give common courtesy to Eric Biederman
> and always CC: him explicitly on any proposed changes you want to make
> to the new MPLS support.
>
> I'm adding him here.

Thank you.  I have been pretty overloaded with catching up on
a couple of other things.  So I have not had as much time as I would
have liked to look at these changes.

Anyone looking at this today should really look at RFC7511 as it seems
releavant.

Eric


>> V2:
>>   - Dropped PHP comment patch to avoid holding up the rest of the
>>     changes due to quibbling on nomenclature.
>>   - Corrected reference to RFC 3031 in commit message of patch
>>     2. Added reference to RFC 3031 s4.1.5 for PHP behaviour.
>>   - s/forwarding/input/ in patch 3.
>>   - Made MPT_IPV4 and MPT_IPV6 equal to 4 and 6 respectively in patch
>>     4, eliminating a switch on the version number as suggested by
>>     review comments. Added back references to RFCs, but moved them to
>>     mpls_payload_type enum declaration.
>> V1:
>>   - Updated to reference the correct RFC in the first patch.
>> 
>> Robert Shearman (4):
>>   mpls: Use definition for reserved label checks
>>   mpls: Differentiate implicit-null and unlabeled neighbours
>>   mpls: Per-device enabling of packet input
>>   mpls: Allow payload type to be associated with label routes
>> 
>>  Documentation/networking/mpls-sysctl.txt |   9 ++
>>  include/linux/netdevice.h                |   4 +
>>  net/mpls/af_mpls.c                       | 226 +++++++++++++++++++++++++------
>>  net/mpls/internal.h                      |   7 +
>>  4 files changed, 203 insertions(+), 43 deletions(-)
>> 
>> -- 
>> 2.1.4
>> 
