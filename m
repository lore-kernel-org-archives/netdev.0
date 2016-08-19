From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net 1/1] net sched ife action: fix encoding to use real
 length
Date: Fri, 19 Aug 2016 16:22:39 +0300
Message-ID: <42438a9c-fe2f-3699-89e9-dc4d59250eba@cogentembedded.com>
References: <1471601860-3336-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
        xiyou.wangcong@gmail.com, mrv@mojatatu.com
To: Jamal Hadi Salim <jhs@mojatatu.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f42.google.com ([209.85.215.42]:33767 "EHLO
        mail-lf0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755298AbcHSNWo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 09:22:44 -0400
Received: by mail-lf0-f42.google.com with SMTP id b199so32889802lfe.0
        for <netdev@vger.kernel.org>; Fri, 19 Aug 2016 06:22:43 -0700 (PDT)
In-Reply-To: <1471601860-3336-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 8/19/2016 1:17 PM, Jamal Hadi Salim wrote:

> From: Jamal Hadi Salim <jhs@mojatatu.com>
>
> Encoding of the metadata was using the padded length as opposed to
> the real length of the data which is a bug per specification.
> This has not been an issue todate because all metadatum specified

    To date? Metadata perhaps?

> so far has been 32 bit where aligned and data length are the same width.
> This also includes a bug fix for validating the length of a u16 field.
> But since there is no metadata of size u16 yes we are fine to include it
> here.
>
> While at it get rid of magic numbers
>
> Fixes: ef6980b6

    This tag has a standardized format, including 12-digit SHA1 and the commit 
summary enclosed in ("").

> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
[...]

MBR, Sergei
