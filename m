From: Einar Lueck <elelueck@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH] tcp: introduce raw access to experimental options
Date: Mon, 03 Dec 2012 19:44:19 +0100
Message-ID: <50BCF303.9020201@linux.vnet.ibm.com>
References: <1353084898-42264-1-git-send-email-elelueck@linux.vnet.ibm.com> <CAK6E8=cXin1rSvQNMPife692wkd5tswsR_7RVG6FNB0rqymHeg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, frankbla@de.ibm.com, raspl@de.ibm.com,
	ubacher@de.ibm.com, samudrala@us.ibm.com, davem@davemloft.net
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp16.uk.ibm.com ([195.75.94.112]:33804 "EHLO
	e06smtp16.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751053Ab2LCSo0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2012 13:44:26 -0500
Received: from /spool/local
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <elelueck@linux.vnet.ibm.com>;
	Mon, 3 Dec 2012 18:44:19 -0000
Received: from d06av12.portsmouth.uk.ibm.com (d06av12.portsmouth.uk.ibm.com [9.149.37.247])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qB3IiDHL63569976
	for <netdev@vger.kernel.org>; Mon, 3 Dec 2012 18:44:13 GMT
Received: from d06av12.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av12.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qB3IiKjW006162
	for <netdev@vger.kernel.org>; Mon, 3 Dec 2012 11:44:21 -0700
In-Reply-To: <CAK6E8=cXin1rSvQNMPife692wkd5tswsR_7RVG6FNB0rqymHeg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/28/2012 01:01 PM, Yuchung Cheng wrote:
> On Sat, Nov 17, 2012 at 12:54 AM,  <elelueck@linux.vnet.ibm.com> wrote:
>> From: Einar Lueck <elelueck@linux.vnet.ibm.com>
>>
>> This patch adds means for raw acces to TCP expirimental options
>> 253 and 254. The intention of this is to enable user space
>> applications to implement communication behaviour that depends
>> on experimental options. For that, new (set|get)sockopts are
>
> Could you elaborate on the use case? I am having a hard time
> understanding that. If you need to use experimental options for your
> applications, why not just use another magic number according to
> draft-ietf-tcpm-experimental-options-02 (since you cite that too)?

We want to enable application programmers to exploit this without
having to change the kernel with all the corresponding implications.

Einar.
