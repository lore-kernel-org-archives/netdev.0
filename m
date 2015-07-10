From: Stas Sergeev <stsp@list.ru>
Subject: Re: [PATCH v2 0/2] net: enable inband link state negotiation only
 when explicitly requested
Date: Fri, 10 Jul 2015 23:45:28 +0300
Message-ID: <55A02EE8.1060008@list.ru>
References: <559FF511.5080102@list.ru> <55A02BB7.8080902@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux kernel <linux-kernel@vger.kernel.org>,
	Sebastien Rannou <mxs@sbrk.org>,
	Arnaud Ebalard <arno@natisbad.org>,
	Stas Sergeev <stsp@users.sourceforge.net>
To: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55A02BB7.8080902@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

10.07.2015 23:31, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On 10/07/15 09:38, Stas Sergeev wrote:
>> Hello.
>>
>> Currently the link status auto-negotiation is enabled
>> for any SGMII link with fixed-link DT binding.
>> The regression was reported:
>> https://lkml.org/lkml/2015/7/8/865
>> Apparently not all HW that implements SGMII protocol, generates the
>> inband status for the auto-negotiation to work.
>> More details here:
>> https://lkml.org/lkml/2015/7/10/206
>>
>> The following patches reverts to the old behavior by default,
>> which is to not enable the auto-negotiation for fixed-link.
>> The new DT property is added that allows to explicitly request
>> the auto-negotiation.
>>
>> Those who were affected by the change, please send your Tested-by,
>> Thanks!
> For future submissions, would you mind CC'ing everybody for the entir=
e
> patch series and not just on a per-patch basis?
I used get_maintainers.pl on a per-patch basis.
This is what SubmittingPatches.txt seems to suggest.
It doesn't say how to produce the CC lists for patch
series, it seems...
Anyway, I'll try to add more recipients to the announce
e-mail next time.
