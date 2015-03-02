From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 4/4] switchdev: don't support custom ip rules,
 for now
Date: Mon, 02 Mar 2015 11:09:32 -0800
Message-ID: <54F4B56C.5040709@cumulusnetworks.com>
References: <1425290777-22702-1-git-send-email-sfeldma@gmail.com> <1425290777-22702-5-git-send-email-sfeldma@gmail.com> <54F4755F.6020205@cumulusnetworks.com> <CAE4R7bALEVb1reyCzfXXi=ifv97jy14ozQuxnG6x9BWmWX10Hg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:37661 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753037AbbCBTJe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 14:09:34 -0500
Received: by pdbnh10 with SMTP id nh10so15928671pdb.4
        for <netdev@vger.kernel.org>; Mon, 02 Mar 2015 11:09:33 -0800 (PST)
In-Reply-To: <CAE4R7bALEVb1reyCzfXXi=ifv97jy14ozQuxnG6x9BWmWX10Hg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/2/15, 9:00 AM, Scott Feldman wrote:
> On Mon, Mar 2, 2015 at 6:36 AM, roopa <roopa@cumulusnetworks.com> wrote:
>> On 3/2/15, 2:06 AM, sfeldma@gmail.com wrote:
>>> From: Scott Feldman <sfeldma@gmail.com>
>>>
>>> Keep switchdev FIB offload model simple for now and don't allow custom ip
>>> rules.
>>>
>>> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>>
>> I don't see a need to do this. And seems very aggressive.
>> Also, note that the rules in a system can be on non-hw accelerated ports.
> It is aggressive but it's the safest choice for the first pass on this
> L3 offload.  Without, switchdev has no way to model custom ip rules
> down to hardware.   Let's start with this aggressive case, and that'll
> force us to work on relaxing it.
>
>
But, this will not allow hw acceleration of routes even if you had a 
rule for the management traffic for example.
