From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: Re: Performance regression 3.11 with macvlan between 2 linux guests
 (bisected)
Date: Thu, 22 Aug 2013 10:23:32 +0200
Message-ID: <5215CA84.8070906@de.ibm.com>
References: <5214B4D4.7020806@de.ibm.com> <52150145.7020801@redhat.com> <521502F6.5030005@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Matthew Rosato <mjrosato@linux.vnet.ibm.com>,
	Jason Wang <jasowang@redhat.com>
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp15.uk.ibm.com ([195.75.94.111]:54732 "EHLO
	e06smtp15.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753641Ab3HVIXj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 04:23:39 -0400
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <borntraeger@de.ibm.com>;
	Thu, 22 Aug 2013 09:17:52 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 1355D17D8059
	for <netdev@vger.kernel.org>; Thu, 22 Aug 2013 09:25:31 +0100 (BST)
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7M8NNvM65929218
	for <netdev@vger.kernel.org>; Thu, 22 Aug 2013 08:23:23 GMT
Received: from d06av03.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r7M8NX1p000982
	for <netdev@vger.kernel.org>; Thu, 22 Aug 2013 02:23:34 -0600
In-Reply-To: <521502F6.5030005@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21/08/13 20:12, Vlad Yasevich wrote:

>>
>> A corrected patch has been sent upstream.  We take into consideration
>> the features on the target device that the user/vm has specified.
>> If the VM has enabled the TSO flags, then nothing will happen to the
>> GSO packet.  However, if the TSO flag is off, segmentation will be
>> performed.
> 
> Particularly.  This commit should fix the issue:
> commit a567dd6252263c8147b7269df5d03d9e31463e11
>  macvtap: simplify usage of tap_features

Tested-by: Christian Borntraeger <borntraeger@de.ibm.com>

The patch is still in net.git, but not in Linus git. Are we going to push this
for 3.11?
