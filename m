From: Jarno Rajahalme <jarno@ovn.org>
Subject: Re: [PATCH v2 net-next 5/9] openvswitch: Refactor labels initialization.
Date: Thu, 9 Feb 2017 11:04:00 -0800
Message-ID: <F1135AFA-8090-40B9-8DD5-4AF70AFF0EE2@ovn.org>
References: <1486582330-31152-1-git-send-email-jarno@ovn.org> <1486582330-31152-6-git-send-email-jarno@ovn.org> <CAPWQB7Gy_pd0ieXqSHXR=W-o0baX30G6yr9BbFLgEVxnP88Qjg@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>
To: Joe Stringer <joe@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33511 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751030AbdBITEf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 14:04:35 -0500
Received: by mail-pg0-f67.google.com with SMTP id 194so1010275pgd.0
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 11:04:02 -0800 (PST)
In-Reply-To: <CAPWQB7Gy_pd0ieXqSHXR=W-o0baX30G6yr9BbFLgEVxnP88Qjg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Feb 8, 2017, at 3:06 PM, Joe Stringer <joe@ovn.org> wrote:
> 
> On 8 February 2017 at 11:32, Jarno Rajahalme <jarno@ovn.org> wrote:
>> Refactoring conntrack labels initialization makes chenges in later
> 
> *changes
> 
>> patches easier to review.
>> 
>> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
> 
> Minor other nit:
> 
>> 
>>        cl = nf_ct_labels_find(ct);
>>        if (!cl) {
>>                nf_ct_labels_ext_add(ct);
>>                cl = nf_ct_labels_find(ct);
>>        }
>> +
>> +       return cl;
>> +}
>> +
>> +/* Initialize labels for a new, to be committed conntrack entry.  Note that
> 
> Maybe insert 'yet':
> 
> Initialize labels for a new, yet to be committed conntrack entry.  Note that


Fixed these typos for v4.

  Jarno
