From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v7 0/4] Support administratively closing application
 sockets
Date: Wed, 16 Dec 2015 14:55:15 -0500
Message-ID: <5671C1A3.30207@mojatatu.com>
References: <1450236605-87170-1-git-send-email-lorenzo@google.com>
 <20151216074334.593a1ad6@xeon-e3>
 <1450281013.8474.73.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Lorenzo Colitti <lorenzo@google.com>, netdev@vger.kernel.org,
	davem@davemloft.net, hannes@stressinduktion.org, ek@google.com,
	tom@herbertland.com, zenczykowski@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:34556 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966353AbbLPTzW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 14:55:22 -0500
Received: by mail-ig0-f180.google.com with SMTP id sf7so39675827igc.1
        for <netdev@vger.kernel.org>; Wed, 16 Dec 2015 11:55:21 -0800 (PST)
In-Reply-To: <1450281013.8474.73.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15-12-16 10:50 AM, Eric Dumazet wrote:
> On Wed, 2015-12-16 at 07:43 -0800, Stephen Hemminger wrote:
>
>>
>> I see no security checks in the diag infrastructure.
>> Up until now diag has been read-only access and therefore has been
>> allowed for all users.
>
> It is still allowed to all users.
>
> Only the 'destroy' operation is restricted.

The question i had was the opposite when i saw this: why are
regular users allowed to read admin (and any other users) details?;->
On this specific feature: why, as a regular user, I cant close
connections attributed to me (and have to use CAP_NET_ADMIN)?

cheers,
jamal
