From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next] switchdev: add support for fdb add/del/dump
 via switchdev_port_obj ops.
Date: Mon, 11 May 2015 09:15:14 -0400
Message-ID: <5550AB62.1060300@mojatatu.com>
References: <1430949253-6358-1-git-send-email-sridhar.samudrala@intel.com>	<554AA530.7000702@mojatatu.com>	<554AED2F.80006@intel.com>	<554CA674.8040905@mojatatu.com> <CAE4R7bBVnC1aLerVR8r0-tpVwk6-P++RCRVKdEgpJDfsYX363g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>,
	Netdev <netdev@vger.kernel.org>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:33207 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751644AbbEKNPR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 09:15:17 -0400
Received: by iepj10 with SMTP id j10so103859504iep.0
        for <netdev@vger.kernel.org>; Mon, 11 May 2015 06:15:16 -0700 (PDT)
In-Reply-To: <CAE4R7bBVnC1aLerVR8r0-tpVwk6-P++RCRVKdEgpJDfsYX363g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/08/15 16:58, Scott Feldman wrote:
> On Fri, May 8, 2015 at 5:05 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>> On 05/07/15 00:42, Samudrala, Sridhar wrote:
>>>

> Bottom line is netlink is not great for in-kernel driver APIs.  Look
> at the fdb and bridge_set/get/dellink ndo ops in netdevice.h to see
> what kind of horse already left the barn.  It's a swayback nag blind
> in one eye and deaf in the other eye.  The problems are:
>

Scott, I dont disagree with you in regarding to the fdb/brport.
The barn has left the deaf-in-the-other-eye horse on that one (yes,
I said that on purpose;->) and it may even make sense to write a
different interface from user  space. I could add more to your list
(why are 8 bits being used to represent a single bit flag for example,
etc).
But what i am worried about is you are setting a trend. I would hate
for this to start looking like SAI when we've had shit working really
well.
You'll find the L3 stuff is more solid in terms of its netlink usage.
But even for the bridge stuff, describing an object as, hiearachy of

An "add" looking like:
   RTM_NEWNEIGH,
      {pointer to attributeid, pointer to attribute value}+

whereas the pointers are to the original TLV (which is still sitting
somewhere in memory) sounds useful.

I dont want to slow you down and i dont have code to demonstrate it -
but hoping I dont need to.

cheers,
jamal
