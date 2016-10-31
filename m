From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Let's do P4
Date: Mon, 31 Oct 2016 19:32:30 +0100
Message-ID: <8285c4a4-791f-c081-7bbc-f6b884ce039a@stressinduktion.org>
References: <20161029075328.GB1692@nanopsycho.orion>
 <20161029154903.25deb6db@jkicinski-Precision-T1700>
 <5814D25D.9070200@gmail.com> <20161030074458.GB1686@nanopsycho.orion>
 <20161030102649.GE1810@pox.localdomain>
 <20161030163836.GC1686@nanopsycho.orion>
 <20161030223903.GA6658@ast-mbp.hil-sfehihf.abq.wayport.net>
 <20161031093922.GA2895@nanopsycho.orion> <58177712.4000208@gmail.com>
 <20161031171229.GB2895@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Thomas Graf <tgraf@suug.ch>, Jakub Kicinski <kubakici@wp.pl>,
        netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
        roopa@cumulusnetworks.com, simon.horman@netronome.com,
        ast@kernel.org, daniel@iogearbox.net, prem@barefootnetworks.com,
        jbenc@redhat.com, tom@herbertland.com, mattyk@mellanox.com,
        idosch@mellanox.com, eladr@mellanox.com, yotamg@mellanox.com,
        nogahf@mellanox.com, ogerlitz@mellanox.com, linville@tuxdriver.com,
        andy@greyhouse.net, f.fainelli@gmail.com, dsa@cumulusnetworks.com,
        vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
        ivecera@redhat.com,
        =?UTF-8?Q?Maciej_=c5=bbenczykowski?= <zenczykowski@gmail.com>
To: Jiri Pirko <jiri@resnulli.us>,
        John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:52529 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S945506AbcJaSch (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 14:32:37 -0400
In-Reply-To: <20161031171229.GB2895@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 31.10.2016 18:12, Jiri Pirko wrote:
>> >
>> >In the naive implementation only pipelines that map 1:1 will work. Maybe
>> >this is what Alexei is noticing?
> P4 is ment to program programable hw, not fixed pipeline.

Is it realistic to assume that future hardware might be programmed with
a proprietary (FPGA-alike) bitstream where a generic API wouldn't fit
anymore? I could imagine vendors shipping a higher abstracted
VHDL/Verilog compiler in the future and expect the kernel just forward
it to the hardware as-is.

Bye,
Hannes
