From: "Du, Fan" <fan.du@intel.com>
Subject: Re: [Query] Delayed vxlan socket creation?
Date: Thu, 15 Dec 2016 16:41:34 +0800
Message-ID: <5852573E.2050007@intel.com>
References: <5A90DA2E42F8AE43BC4A093BF06788481A9457F1@SHSMSX103.ccr.corp.intel.com> <20161214102931.307efe94@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "mrjana@gmail.com" <mrjana@gmail.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:11712 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757392AbcLOIvp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Dec 2016 03:51:45 -0500
In-Reply-To: <20161214102931.307efe94@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



在 2016年12月14日 17:29, Jiri Benc 写道:
> On Wed, 14 Dec 2016 07:49:24 +0000, Du, Fan wrote:
>> I'm interested to one Docker issue[1] which looks like related to kernel vxlan socket creation
>> as described in the thread. From my limited knowledge here, socket creation is synchronous ,
>> and after the *socket* syscall, the sock handle will be valid and ready to linkup.
>>
>> Somehow I'm not sure the detailed scenario here, and which/how possible commit fix?
> baf606d9c9b1^..56ef9c909b40
>
>   Jiri

Thanks a lot Jiri!
