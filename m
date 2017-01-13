From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH iproute2] Add support for rt_protos.d
Date: Thu, 12 Jan 2017 19:11:44 -0700
Message-ID: <0f141758-4227-b3fd-802a-bcd891ee8402@cumulusnetworks.com>
References: <1484005389-29381-1-git-send-email-dsa@cumulusnetworks.com>
 <20170112172706.4832fb67@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:35331 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751069AbdAMCLw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 21:11:52 -0500
Received: by mail-pf0-f175.google.com with SMTP id f144so22410712pfa.2
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 18:11:51 -0800 (PST)
In-Reply-To: <20170112172706.4832fb67@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/12/17 6:27 PM, Stephen Hemminger wrote:
>> diff --git a/etc/iproute2/rt_protos.d/README b/etc/iproute2/rt_protos.d/README
>> new file mode 100644
>> index 000000000000..723509ce56b6
>> --- /dev/null
>> +++ b/etc/iproute2/rt_protos.d/README
>> @@ -0,0 +1,3 @@
>> +Each file in this directory is an rt_protos configuration file. iproute2
>> +commands scan this directory processing all files that end in '.conf'.
>> +
> 
> Applied, but required manual fixup.
> 
> 
> .git/rebase-apply/patch:15: new blank line at EOF.
> +
> warning: 1 line adds whitespace errors.
> 

yes, i noticed that when I applied the patch to our local repo. It's a copy of the rt_tables.d patch and that README has the extra newline too.
