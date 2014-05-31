From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH iproute2] bridge: Add master device name to bridge fdb
 show
Date: Sat, 31 May 2014 07:10:31 -0400
Message-ID: <5389B8A7.8030301@mojatatu.com>
References: <1401255611-30862-1-git-send-email-roopa@cumulusnetworks.com> <53864051.4070102@gmail.com> <53869320.6010302@cumulusnetworks.com> <20140530073614.0a48f2bd@nehalam.linuxnetplumber.net> <53895A48.2040203@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, wkok@cumulusnetworks.com,
	sfeldma@cumulusnetworks.com, shm@cumulusnetworks.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:52740 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754558AbaEaLKi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 May 2014 07:10:38 -0400
Received: by mail-ie0-f169.google.com with SMTP id rp18so1561410iec.28
        for <netdev@vger.kernel.org>; Sat, 31 May 2014 04:10:38 -0700 (PDT)
In-Reply-To: <53895A48.2040203@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/31/14 00:27, Roopa Prabhu wrote:
> On 5/30/14, 7:36 AM, Stephen Hemminger wrote:

> but set also uses 'master' ..and the bridge is referenced using 'master'
> in almost all commands
> #ip link set dev brport master brdev
>
> so, using 'bridge' and 'master' interchangeably seems a bit confusing.
>
> But, if  the preference is 'bridge' i will resubmit this patch with
> 'bridge' shortly.

Sorry - I guess until i looked at the code again last few minutes,
it had skipped my mind that this interface is also used for vxlan. So 
master now seems to make more sense ;->

Vlad, you may get your wish - it seems if i am going to have to set
the bridge device as a filter I will have no choice but to use an
ifm since it is size different from ndm. Which is not a big deal
until i attach an attribute - which breaks old iproute2  out in
the wild already. I have to say i am not liking this (because i was
hoping to add other filters in the future, example vlan)
but dont see a way out.
So the only way this would work is to use the original ifm as
the header.

cheers,
jamal
