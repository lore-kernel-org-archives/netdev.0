From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v2 2/4] swdevice: add new api to set and del
 bridge port attributes
Date: Mon, 15 Dec 2014 10:26:12 -0500
Message-ID: <548EFD94.8070905@mojatatu.com>
References: <1418202320-19491-3-git-send-email-roopa@cumulusnetworks.com> <20141210093755.GB1863@nanopsycho.orion> <5489CBBA.7050302@cumulusnetworks.com> <20141211171145.GG1912@nanopsycho.orion> <5489DB73.1080808@cumulusnetworks.com> <20141211180743.GA2010@nanopsycho.orion> <5489E214.4080708@cumulusnetworks.com> <20141211222559.GB1880@nanopsycho.orion> <548D9B14.9010201@cumulusnetworks.com> <20141214153549.GA2174@nanopsycho.orion> <548DE7E2.6010705@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, bcrl@kvack.org, tgraf@suug.ch,
	john.fastabend@gmail.com, stephen@networkplumber.org,
	linville@tuxdriver.com, vyasevic@redhat.com,
	netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>,
	Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:62849 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751462AbaLOP0P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2014 10:26:15 -0500
Received: by mail-ie0-f171.google.com with SMTP id rl12so10888462iec.16
        for <netdev@vger.kernel.org>; Mon, 15 Dec 2014 07:26:14 -0800 (PST)
In-Reply-To: <548DE7E2.6010705@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Sorry - i didnt quiet follow the discussion, but i can see the value
of propagating things from parent to children netdevs as part of the
generic approach. And in that spirit:

Ben's patches (and I am sure the cumulus folk do this) expose ports.
i.e you boot up the hardware and you see ports. You can then put these
ports in a bridge and you can offload fdbs and do other parametrization
to the ASIC. IOW, this only becomes a bridge because you created one
in the kernel and attached bridge ports to it.

Lets say i didnt want a bridge. I want instead to take these exposed
ports and create a bond (and maybe play with LACP). How does this
propagation from parent->child->child work then? I think the idea
of just bonding and not exposing it as a switch is a reasonable use
case.
Also how does it work when i start doing L3 and the bond's port doesnt
support L3? Is it time to revive the thing we called TheThing in Du?

cheers,
jamal

On 12/14/14 14:41, Roopa Prabhu wrote:
> On 12/14/14, 7:35 AM, Jiri Pirko wrote:

[..chopped off for brevity and saving electrons..]

cheers,
jamal
