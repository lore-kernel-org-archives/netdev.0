From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 1/5] vxlan: Group Policy extension
Date: Wed, 14 Jan 2015 18:59:58 -0800
Message-ID: <CA+mtBx8S8FcJrOdPgTC7oRcSyayQLox=SRc3-N1YQ5+VoVWbyA@mail.gmail.com>
References: <cover.1421280226.git.tgraf@suug.ch>
	<c73939bbb55a8e450de7931d830e0467a8340665.1421280226.git.tgraf@suug.ch>
	<CA+mtBx-CH2=D-wKmkjVTvhQOWhbf73NxcGrXrXOPE-E2PzJajQ@mail.gmail.com>
	<20150115002323.GH2105@casper.infradead.org>
	<CA+mtBx9=coY1YwPn2ds66PD-J7FDaN_3Yf-_nB_vUEeZEDyJdg@mail.gmail.com>
	<20150115012804.GI2105@casper.infradead.org>
	<20150115025539.GA20315@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.ne>, Jesse Gross <jesse@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:35363 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751031AbbAOC76 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 21:59:58 -0500
Received: by mail-ig0-f169.google.com with SMTP id z20so1171184igj.0
        for <netdev@vger.kernel.org>; Wed, 14 Jan 2015 18:59:58 -0800 (PST)
In-Reply-To: <20150115025539.GA20315@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 14, 2015 at 6:55 PM, Thomas Graf <tgraf@suug.ch> wrote:
> On 01/15/15 at 01:28am, Thomas Graf wrote:
>> What exactly is the problem of having a distinct bitmap used by
>> extensions? It is the least error prone method because it's clear that
>> all extensions must match and we don't have to maintain an additional
>> bitmask which can be forgotten to be updated.
>>
>> If you need to compare additional receive checksum settings for RCO
>> then that should be separate because as you say it's not an extension.
>
> Tom,
>
> OK. I have changed it to use flags instead of exts in v6. You should
> be able to add whatever RCO flags need to be matched in
> vxlan_find_sock() to the VXLAN_F_UNSHAREABLE bitmask.
>
> Hope this makes everybody happy ;-)

Awesome. Thanks!
