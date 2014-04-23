From: Li RongQing <roy.qing.li@gmail.com>
Subject: Re: [PATCH][net-next] tcp: remove the duplicate prefixes in the
 logging message
Date: Wed, 23 Apr 2014 21:32:43 +0800
Message-ID: <CAJFZqHxg9YSmHWb9DgmdtO01vVz3vN86DaCNdswRtZviemh3mQ@mail.gmail.com>
References: <1398245335-18780-1-git-send-email-roy.qing.li@gmail.com>
	<5357897D.8060809@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>, joe@perches.com
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f173.google.com ([209.85.216.173]:40105 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754838AbaDWNcv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 09:32:51 -0400
Received: by mail-qc0-f173.google.com with SMTP id r5so887661qcx.4
        for <netdev@vger.kernel.org>; Wed, 23 Apr 2014 06:32:50 -0700 (PDT)
In-Reply-To: <5357897D.8060809@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 23, 2014 at 5:35 PM, Daniel Borkmann <dborkman@redhat.com> wrote:
> On 04/23/2014 11:28 AM, roy.qing.li@gmail.com wrote:
>>
>> From: Li RongQing <roy.qing.li@gmail.com>
>>
>> The current message is:
>>         TCP: TCP: Possible SYN flooding on port 80. Sending cookies. ...
>>
>> The cause is that pr_info will implicitly print the pr_fmt string, which
>> is standard
>> prefix, and explicitly print the "proto" which is "TCP:" too
>>
>> it is unsuitable to not print proto, since proto maybe TCPv6, so use
>> printk directly.
>
>
> Can't you just leave the pr_info() instead, and reword that into something
> like:
>
>   "Possible %s SYN flooding[...]", proto
To ipv4:

TCP: Possible TCP SYN flooding on port 80. Sending cookies. ...

To ipv6:

TCP: Possible TCPv6 SYN flooding on port 80. Sending cookies. ...


I think there are two "TCP" still, and it is  duplicate;


-Roy
