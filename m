From: =?ISO-8859-15?Q?Pavel_=A6imerda?= <pavlix@pavlix.net>
Subject: Re: [PATCH 5/7] ip-route: don't hide routes with RTM_F_CLONED by
 default
Date: Mon, 11 May 2015 19:48:28 +0200
Message-ID: <5550EB6C.9070607@pavlix.net>
References: <1428933661-8193-2-git-send-email-pavlix@pavlix.net>	<1428933661-8193-5-git-send-email-pavlix@pavlix.net>	<20150504083751.7c38626b@urahara> <20150504.143708.1105742826058228400.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, psimerda@redhat.com
To: David Miller <davem@davemloft.net>, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fox.pavlix.net ([84.246.161.104]:56695 "EHLO fox.pavlix.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751474AbbEKRuJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 May 2015 13:50:09 -0400
In-Reply-To: <20150504.143708.1105742826058228400.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/04/2015 08:37 PM, David Miller wrote:
> From: Stephen Hemminger <stephen@networkplumber.org>
> Date: Mon, 4 May 2015 08:37:51 -0700
>=20
>> On Mon, 13 Apr 2015 16:00:59 +0200
>> Pavel =A6imerda <pavlix@pavlix.net> wrote:
>>
>>> From: Pavel =A6imerda <psimerda@redhat.com>
>>>
>>> Signed-off-by: Pavel =A6imerda <psimerda@redhat.com>
>>> ---
>>>  ip/iproute.c | 2 +-
>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> I understand your concern, and it probably was a poor design choice =
initially.
>>
>> Since this will change the output for the default case, it will upse=
t some
>> peoples expectations and potentially break scripts that screen scrap=
e the output
>> of ip commands. Therefore I can't accept it at this time.
>>
>> Sorry for the delay, but I thought someone else would add more comme=
nts.
>> Perhaps if you explained in more detail the motivation of why this i=
s an
>> important problem I would reconsider change the behavior.

Hi,

I have no specific concern right now.

> We definitely need to report routes created by caching/cloning separa=
tely
> from the main FIB entries.
>=20
> And I agree that even if we wanted to change behavior, the horse has
> already left the barn on this one and therefore there is no way we ca=
n
> change this now.

=46or now I treat the patch as rejected by upstream and as I'm not awar=
e
of a specific concern for Fedora, I'm also dropping the patch from the
development branch[1]. Thank you for accepting other patches.

My plan is to submit new patches for requests coming from Fedora and
RHEL distributions and also resubmit the manpage patches with new
changes and split by command/subcommand.

Cheers,

Pavel

[1]:
http://pkgs.fedoraproject.org/cgit/iproute.git/commit/?id=3Df0557f39740=
b5c18f07b2caf634eb073ba19484f
