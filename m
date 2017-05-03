From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next RFC 1/1] net netlink: Add new type NLA_FLAG_BITS
Date: Tue, 2 May 2017 21:52:19 -0400
Message-ID: <a719bd37-9e60-8ce2-c5d5-cbc9195a4f62@mojatatu.com>
References: <1493562519-15563-1-git-send-email-jhs@emojatatu.com>
 <20170502.150345.954488149548327006.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, xiyou.wangcong@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:35953 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751144AbdECBw3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 21:52:29 -0400
Received: by mail-it0-f67.google.com with SMTP id x188so4731831itb.3
        for <netdev@vger.kernel.org>; Tue, 02 May 2017 18:52:28 -0700 (PDT)
In-Reply-To: <20170502.150345.954488149548327006.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-05-02 03:03 PM, David Miller wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
> Date: Sun, 30 Apr 2017 10:28:39 -0400
>
>> Generic bitflags attribute content sent to the kernel by user.
>> With this type the user can either set or unset a flag in the
>> kernel.
>
> You asked for feedback, here it is :-)
>
> I think this is overengineered.
>
> Just define a u32 for the value, and mask which defines which bits are
> legitimate and defined.  Any bit outside of the legitimate mask must
> be zero.
>

That is what it does but as a nla type. It has a validator ops() in
case someone wants to override the default validator.
Is the ops the over-engineering you refer to or merely making it an
nla type is a problem?

cheers,
jamal
