From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 4/4] switchdev: don't support custom ip
 rules, for now
Date: Mon, 02 Mar 2015 15:30:00 -0500 (EST)
Message-ID: <20150302.153000.14374017304430703.davem@davemloft.net>
References: <1425290777-22702-5-git-send-email-sfeldma@gmail.com>
	<54F4755F.6020205@cumulusnetworks.com>
	<CAE4R7bALEVb1reyCzfXXi=ifv97jy14ozQuxnG6x9BWmWX10Hg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, netdev@vger.kernel.org, jiri@resnulli.us
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53523 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751914AbbCBUaD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 15:30:03 -0500
In-Reply-To: <CAE4R7bALEVb1reyCzfXXi=ifv97jy14ozQuxnG6x9BWmWX10Hg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>
Date: Mon, 2 Mar 2015 09:00:58 -0800

> On Mon, Mar 2, 2015 at 6:36 AM, roopa <roopa@cumulusnetworks.com> wrote:
>> On 3/2/15, 2:06 AM, sfeldma@gmail.com wrote:
>>>
>>> From: Scott Feldman <sfeldma@gmail.com>
>>>
>>> Keep switchdev FIB offload model simple for now and don't allow custom ip
>>> rules.
>>>
>>> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>>
>>
>> I don't see a need to do this. And seems very aggressive.
>> Also, note that the rules in a system can be on non-hw accelerated ports.
> 
> It is aggressive but it's the safest choice for the first pass on this
> L3 offload.  Without, switchdev has no way to model custom ip rules
> down to hardware.   Let's start with this aggressive case, and that'll
> force us to work on relaxing it.

+1
