From: Joe Harvell <joe.harvell@tekcomms.com>
Subject: Re: [PATCH]: iproute2: enhance enforcement of ifconfig compatible
 address labels and allow non-compatible ones with -force
Date: Tue, 24 Mar 2015 17:55:36 -0500
Message-ID: <5511EB68.5070604@tekcomms.com>
References: <4edec6f657e24e98b938c3ad76b54625@BRMWP-EXMB11.corp.brocade.com>
 <20150324151114.7168de0b@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Vadim Kochan <vadim4j@gmail.com>
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0133.outbound.protection.outlook.com ([207.46.100.133]:64336
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751842AbbCXX3h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Mar 2015 19:29:37 -0400
In-Reply-To: <20150324151114.7168de0b@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 24/03/2015 17:11, Stephen Hemminger a =E9crit :
> On Sat, 21 Mar 2015 17:55:02 +0000
> Joe Harvell <joe.harvell@tekcomms.com> wrote:
>
>> The ip addr command today rejects address labels that would break
>> ifconfig.  However, it allows some labels which still break it. Enha=
nce
>> enforcement to reject all known incompatible labels, and allow the
>> existing -force option to allow someone to use a label even if it is=
 not
>> ifconfig compatible
>>
>> Make existing -force option of ip addr add skip enforcment of ifconf=
ig
>> compatible address labels.
>> Change enforcement to properly reject labels that do begin with
>> <devname> but are followed by a string that does not begin with colo=
n.
>>
>>
>> The following changes since commit 4612d04d6b8f07274bd5d0688f717ccc1=
89499ad:
>>
>>     tc class: Show class names from file (2015-03-15 12:27:40 -0700)
>>
>> are available in the git repository at:
>>
>>     git@github.com:jharvell/iproute2.git addr-label-noncompat
>>
>> for you to fetch changes up to 6a1d09e93ae1fb4f7f1cd5981813af918e8ef=
c88:
> Not really enthusiastic about this. It seems to introduce more issues
> and I don't consider it a big issue. If user is creating labels with
> ip and it breaks ifconfig, it is really a case of shooting themselves
> in the foot; or the fact that ifconfig needs to die (or get fixed).
Actually, I agree.  My real motivation for this change is to be able to
create labels that are currently being rejected.  I did this through
a -force option because I assumed no one would agree to remove the
enforcement altogether.  When I noticed during my testing that the
existing enforcement doesn't even catch all the lables that break ifcon=
fig,
I decided to enhance it.  But I'm totally fine with just removing the=20
existing
enforcement altogether.
