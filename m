From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH RFC net-next] arp: Really delete an arp entry on "arp -d"
Date: Tue, 30 May 2017 18:42:22 -0600
Message-ID: <de8d048e-a276-c596-6b98-c9e7c4b91270@gmail.com>
References: <1496116096-77316-1-git-send-email-sowmini.varadhan@oracle.com>
 <20170530162020.137aef02@xeon-e3> <20170530233232.GL23089@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:34435 "EHLO
        mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750902AbdEaAmZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 20:42:25 -0400
Received: by mail-io0-f171.google.com with SMTP id k91so3200702ioi.1
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 17:42:25 -0700 (PDT)
In-Reply-To: <20170530233232.GL23089@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/30/17 5:32 PM, Sowmini Varadhan wrote:
> On (05/30/17 16:20), Stephen Hemminger wrote:
>>
>> Please don't copy/paste chunks of code. Instead refactor and make this
>> into a helper function. 
> 
> sure, I have no problems with that, and as I pointed out, I've not
> tested ipv6 for this yet either. I'll do all of this after getting
> some feedback on the more basic issue here:
> 
> I was first looking for comments on the more fundamental refcnt
> management behind the fix (I'm surprised no one noticed this 
> before, is there some deep reason for leaving it like this, that
> I am missing? Does it break something else?)

It has been noticed. I have not sent a patch since adjusting gc
parameters will reclaim FAILED entries at whatever rate the user wants.
