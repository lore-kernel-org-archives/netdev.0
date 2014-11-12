From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next 2/2] sched: introduce vlan action
Date: Wed, 12 Nov 2014 07:27:24 -0500
Message-ID: <5463522C.1030104@mojatatu.com>
References: <1415700789-9171-1-git-send-email-jiri@resnulli.us> <1415700789-9171-2-git-send-email-jiri@resnulli.us> <CAHA+R7P1PM5=TJYRPPrYc_U4AnLvsgQPZr0coTbeijAUGvB9zg@mail.gmail.com> <20141112074755.GA1882@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Pravin B Shelar <pshelar@nicira.com>,
	Tom Herbert <therbert@google.com>,
	Eric Dumazet <edumazet@google.com>, willemb@google.com,
	Daniel Borkmann <dborkman@redhat.com>, mst@redhat.com,
	Florian Westphal <fw@strlen.de>, Paul.Durrant@citrix.com,
	Thomas Graf <tgraf@suug.ch>
To: Jiri Pirko <jiri@resnulli.us>, Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:43659 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752005AbaKLM11 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2014 07:27:27 -0500
Received: by mail-ig0-f169.google.com with SMTP id hn18so2872228igb.0
        for <netdev@vger.kernel.org>; Wed, 12 Nov 2014 04:27:27 -0800 (PST)
In-Reply-To: <20141112074755.GA1882@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/12/14 02:47, Jiri Pirko wrote:
> Wed, Nov 12, 2014 at 12:18:47AM CET, cwang@twopensource.com wrote:

>> I know vlan tag is not exactly the skb metadata, but still seems
>> fits in skbedit for me.
>
> I was thinking about that as well. It seems much clearer to add a new
> action.
>

Cong,
I think it is better to have all these "tunneling" activities
as a separate action each. It is cleaner from a usability perspective.
[e.g. it is not hard to express nat action with pedit action or take
checksum out of nat since we have a csum action), but makes sense to
have it separate)].

cheers,
jamal
