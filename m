From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next v3 0/4] mpls: Behaviour-changing improvements
Date: Thu, 2 Apr 2015 00:49:38 +0100
Message-ID: <551C8412.6060104@brocade.com>
References: <1426866170-28739-1-git-send-email-rshearma@brocade.com>	<1427739356-28113-1-git-send-email-rshearma@brocade.com> <20150401.153041.376950284605107486.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"ebiederm@xmission.com" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:27768 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751533AbbDAXtz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 19:49:55 -0400
In-Reply-To: <20150401.153041.376950284605107486.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/04/15 20:30, David Miller wrote:
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

Sorry for the oversight of not copying him on the cover letter. FWIW, he 
was copied on the individual patches so the intention was to give Eric 
that courtesy.

>
> I'm adding him here.
>
>> V2:
>>    - Dropped PHP comment patch to avoid holding up the rest of the
>>      changes due to quibbling on nomenclature.
>>    - Corrected reference to RFC 3031 in commit message of patch
>>      2. Added reference to RFC 3031 s4.1.5 for PHP behaviour.
>>    - s/forwarding/input/ in patch 3.
>>    - Made MPT_IPV4 and MPT_IPV6 equal to 4 and 6 respectively in patch
>>      4, eliminating a switch on the version number as suggested by
>>      review comments. Added back references to RFCs, but moved them to
>>      mpls_payload_type enum declaration.
>> V1:
>>    - Updated to reference the correct RFC in the first patch.
>>
>> Robert Shearman (4):
>>    mpls: Use definition for reserved label checks
>>    mpls: Differentiate implicit-null and unlabeled neighbours
>>    mpls: Per-device enabling of packet input
>>    mpls: Allow payload type to be associated with label routes
>>
>>   Documentation/networking/mpls-sysctl.txt |   9 ++
>>   include/linux/netdevice.h                |   4 +
>>   net/mpls/af_mpls.c                       | 226 +++++++++++++++++++++++++------
>>   net/mpls/internal.h                      |   7 +
>>   4 files changed, 203 insertions(+), 43 deletions(-)
>>
>> --
>> 2.1.4
>>
