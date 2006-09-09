From: Patrick McHardy <kaber@trash.net>
Subject: Re: IPSec broken in 2.6.18-rc4-mm3
Date: Sat, 09 Sep 2006 15:56:46 +0200
Message-ID: <4502C81E.600@trash.net>
References: <fa4052ef0609080926j5bbae070mccb9699f0e5eb1fb@mail.gmail.com>	 <4501CA01.3050904@trash.net> <fa4052ef0609081332l3c4d25a3xe5e315482884e1a8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62672 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S932187AbWIIN43
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Sep 2006 09:56:29 -0400
To: Gnome42 Gnome42 <gnome42@gmail.com>
In-Reply-To: <fa4052ef0609081332l3c4d25a3xe5e315482884e1a8@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gnome42 Gnome42 wrote:
> On 9/8/06, Patrick McHardy <kaber@trash.net> wrote:
>>
>> Can you see the decrypted packets on the incoming interface on the
>> other side?
> 
> 
> No, not the decrypted ones only the encrypted ones. I never see the
> decrypted packets. ( I should see them twice right? Once encrypted and
> once decrypted?)

Yes.

>> Please post your policies and related SAs from both sides.
>> Are you using NAT, iptables or anything like that?
> 
> 
> [...]
> ... or did you mean dumps from setkey -D[P]?

Yes, I meant the SAs. But please use "ip -s xfrm state" and "ip -s xfrm
policy" (on both sides), they include a bit more information than
setkey.

