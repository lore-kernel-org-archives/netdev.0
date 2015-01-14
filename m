From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: non-OVS based vxlan config broken on 3.19-rc ?!
Date: Wed, 14 Jan 2015 22:55:33 +0200
Message-ID: <CAJ3xEMj+rjTmk2tbVCTMCp+7N0qwXBNf3JsbJEgh2qvq0jHmEg@mail.gmail.com>
References: <54B688D9.8030101@mellanox.com>
	<20150114155208.GA24550@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	tom Herbert <therbert@google.com>,
	Marcelo Leitner <mleitner@redhat.com>,
	Jesse Gross <jesse@nicira.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:44643 "EHLO
	mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751286AbbANUze (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 15:55:34 -0500
Received: by mail-oi0-f54.google.com with SMTP id u20so9243259oif.13
        for <netdev@vger.kernel.org>; Wed, 14 Jan 2015 12:55:33 -0800 (PST)
In-Reply-To: <20150114155208.GA24550@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 14, 2015 at 5:52 PM, thomas Graf <tgraf@suug.ch> wrote:
> On 01/14/15 at 05:18pm, Or Gerlitz wrote:
>> Guys, just realized that non-OVS based vxlan config is broken with
>> 3.19-rc... I see that it works for me on 3.18.2 and breaks on 3.19-rc3
>> (Linus tree). Tested over mlx4 (both offloaded and non offloaded modes) and
>> igb, see below the simplest form I can see it breaks on 3.19-rcand works on
>> 3.18
>>
>> Looking on tcpdump and stats, the arp reply arrives to the 3.19-rc host NIC
>> driver but is dropped along the stack beforehanded to the vxlan driver, not
>> sure where and why...
>
> As additional data point: I tested the VXLAN-GBP with iproute2 based tunnels
> on net-next and that works fine. Driver used was a e1000 in KVM.


mm, so net-next.git (3.20 candidate code) and 3.18 works, but @ least
for me 3.19-rc doesn't - could you check if net.git works for you on
iproute2 based tunnels in that env? just vxlan is enough.
