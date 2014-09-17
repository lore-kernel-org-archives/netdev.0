From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [PATCH v7 ethtool 0/2] patchset - Support for configurable RSS
 hash key
Date: Wed, 17 Sep 2014 10:55:29 +0200
Message-ID: <54194C81.2020109@redhat.com>
References: <e8020e05-df87-4251-90b1-cbaf53296631@CMEXHTCAS1.ad.emulex.com> <BF3270C86E8B1349A26C34E4EC1C44CB2C908A15@CMEXMB1.ad.emulex.com> <53E86A79.8010700@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "ben@decadent.org.uk" <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1031 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751754AbaIQIzR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Sep 2014 04:55:17 -0400
In-Reply-To: <53E86A79.8010700@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11.8.2014 09:02, Ivan Vecera wrote:
> On 31.7.2014 09:43, Venkat Duvvuru wrote:
>>
>>
>>> -----Original Message-----
>>> From: netdev-owner@vger.kernel.org [mailto:netdev-
>>> owner@vger.kernel.org] On Behalf Of Venkat Duvvuru
>>> Sent: Tuesday, July 22, 2014 5:51 PM
>>> To: ben@decadent.org.uk
>>> Cc: netdev@vger.kernel.org; Venkat Duvvuru
>>> Subject: [PATCH v7 ethtool 0/2] patchset - Support for configurable
>>> RSS hash
>>> key
>>>
>>> NIC drivers that support RSS use either a hard-coded value or a
>>> random value
>>> for the RSS hash key. Irrespective of the type of the key used, the user
>>> would want to change the hash key if he/she is not satisfied with the
>>> effectiveness of the default hash-key in spreading the incoming flows
>>> evenly
>>> across the RSS queues.
>>>
>>> This patch set adds support for configuring the RSS hash-key via the
>>> ethtool
>>> interface using -X/-x option.
>>>
>>> v7:
>>> 1. Changed rss string to RSS to be consistent with other parts of the
>>> error
>>> codes
>>>     and documentation.
>>> 2. Corrected a few error messages
>>> 3. Changed error codes to use either 1 or 2 based on the situation
>>> 4. Added test cases in test-cmdline.c
>>>
>>> Venkat Duvvuru (2):
>>>    ethtool: Support for configurable RSS hash key.
>>>    ethtool: Support for configurable RSS hash key.
>>>
>>>   ethtool-copy.h |  478
>>> ++++++++++++++++++++++++++++++++++++++++++--------------
>>>   ethtool.8.in   |   18 ++-
>>>   ethtool.c      |  393 +++++++++++++++++++++++++++++++++++++++--------
>>>   test-cmdline.c |   11 ++
>>>   4 files changed, 717 insertions(+), 183 deletions(-)
>>
>> Ben, Please let me know if you have any further comments on this.
>>
>> /Venkat.
> Hi Ben,
> any objection?
>
> Ivan
Ben, is there any problem with this??

Ivan
