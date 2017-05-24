From: Ihar Hrachyshka <ihrachys@redhat.com>
Subject: Re: [PATCH v2 0/4] arp: always override existing neigh entries with
 gratuitous ARP
Date: Wed, 24 May 2017 14:32:39 -0700
Message-ID: <23f8a3fa-3e7a-339a-2deb-76d20fe6483b@redhat.com>
References: <cover.1495136258.git.ihrachys@redhat.com>
 <CAK8P3a162_RdXHLCPzg47+F7yadRGMDgFG_z5R6v65-heY1KAw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, ja@ssi.bg,
        Networking <netdev@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f169.google.com ([209.85.220.169]:34683 "EHLO
        mail-qk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941010AbdEXVcm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 17:32:42 -0400
Received: by mail-qk0-f169.google.com with SMTP id k74so164875666qke.1
        for <netdev@vger.kernel.org>; Wed, 24 May 2017 14:32:42 -0700 (PDT)
In-Reply-To: <CAK8P3a162_RdXHLCPzg47+F7yadRGMDgFG_z5R6v65-heY1KAw@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/23/2017 01:56 PM, Arnd Bergmann wrote:
> This seems to have caused a build warning:
>
> net/ipv4/arp.c:880:35: warning: 'addr_type' may be used uninitialized
> in this function [-Wmaybe-uninitialized]
>
Not sure. How do you reproduce it? I just did 'make net' in the latest 
tree that includes the patch, and it doesn't trigger the failure. Also 
the code logic prevents it to be uninitialized (it's always set to -1 or 
the actual type value).

Please advise,
Ihar
