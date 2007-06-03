From: Strobl Anton <a.strobl@aws-it.at>
Subject: Re: OOPS iproute2/tc/u32_destroy in 2.6.22-rc3-git6
Date: Sun, 03 Jun 2007 19:48:56 +0200
Message-ID: <20070603194856.9eyyeukhesgw0owg@bigboss.aws-it.at>
References: <20070603161814.q5x2jsq8dck4gcgw@bigboss.aws-it.at>
	<4662D881.5080600@googlemail.com> <4662EE12.1080400@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=ISO-8859-15;
	DelSp="Yes";
	format="flowed"
Content-Transfer-Encoding: 7bit
Cc: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>,
	linux-kernel@vger.kernel.org, Netdev <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757488AbXFCRtP@vger.kernel.org>
In-Reply-To: <4662EE12.1080400@trash.net>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patch for sch_cbq.c works perfect - no more kernel panic!
(sch_atm.c => im not able to test atm shaping, sorry)

Thank you for the fast response to my request!

Strobl Anton

<a dot strobl at aws-it dot at>


Zitat von Patrick McHardy <kaber@trash.net>:

> Michal Piotrowski wrote:
>> Strobl Anton pisze:
>>
>>> While trying to stop qdisc/cbq with command
>>>
>>>    tc qdisc del dev eth1 root
>>>
>>> EIP is at u32_destroy+0x52/0xd8 [cls_u32]
>
>
> Please try this patch.
>
>
