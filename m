From: Andy Furniss <andyqos@ukfsn.org>
Subject: Re: [Announce] LARTC wiki available
Date: Sat, 02 Jun 2012 15:37:57 +0100
Message-ID: <4FCA2545.60702@ukfsn.org>
References: <4EFB3B2B.7060200@linuxsystems.it> <4FC8F0E4.6060102@linuxsystems.it> <8063b8e35d17fd072cbdc9908cf12519@njm.linuxwall.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?TmljY29sw7IgQmVsbGk=?= <darkbasic@linuxsystems.it>,
	lartc@vger.kernel.org, netfilter@vger.kernel.org,
	Linux Networking Developer Mailing List
	<netdev@vger.kernel.org>
To: Julien Vehent <julien@linuxwall.info>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <8063b8e35d17fd072cbdc9908cf12519@njm.linuxwall.info>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Julien Vehent wrote:
> On 2012-06-01 12:42, Niccol=C3=B2 Belli wrote:
>> http://lartc.org is alive and kicking and there is no need for
>> another
>> wiki anymore. I'd like to thank both Bert and Carl-Daniel.
>>
>> Niccol=C3=B2
>>
>
> Very cool !
> I'll try to find some time and move over some of the content I have
> here:
> http://wiki.linuxwall.info/doku.php/en:ressources:dossiers:networking=
:traffic_control

A couple of things that stand out after skimming through.

DSL - Jeesper's overhead as noted in the comments is not 5 and anyway I=
=20
think his good work has now been superseded by stab as it allows for=20
negative overheads, which his did not.

man tc-stab has clear and good explanations and examples.

SFQ - well it's literally been years since I knew it in detail, but=20
limit was (back then at least) for all flows combined.

I tested (maybe not hard enough) quantum < mtu and never managed to=20
prevent dequeues - I know it's not efficient and "forbiden" but back=20
then at least it didn't break.

Anyway it seems that early this year SFQ got some love and now has=20
several more options (red, headdrop, limit >127, depth as param) - so a=
s=20
long as your iproute/kernel is current have a look at man tc-sfq for=20
details.
