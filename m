From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: [Lxc-users] Bad checksums and lost packets with macvlan on dummy
Date: Thu, 24 Feb 2011 11:20:09 +0100
Message-ID: <4D6630D9.2050400@free.fr>
References: <20110221150710.GA5651@nord.niifaq.ru> <4D6282DB.2080204@free.fr> <20110221153421.GA6602@nord.niifaq.ru> <4D628DC3.9000400@free.fr> <20110223170512.GA10277@nord.niifaq.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: lxc-users@lists.sourceforge.net, Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Andrian Nord <nightnord@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-g21.free.fr ([212.27.42.6]:52041 "EHLO smtp6-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751693Ab1BXKUU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Feb 2011 05:20:20 -0500
In-Reply-To: <20110223170512.GA10277@nord.niifaq.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/23/2011 06:13 PM, Andrian Nord wrote:
> On Mon, Feb 21, 2011 at 05:07:31PM +0100, Daniel Lezcano wrote:
>> I Cc'ed the netdev mailing list and Patrick in case my analysis is wrong
>> or incomplete.
> I'm confirming, that this happens only when macvlan's are onto dummy net
> device. In case of some physical interface under macvlan there is no lost
> packages and no broken checksums.
Hmm, that's interesting ...

I saw you were using the command 'nc6', do you use netcat with ipv6 ?
