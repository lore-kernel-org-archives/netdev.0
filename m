From: =?UTF-8?Q?Andreas_F=c3=a4rber?= <afaerber@suse.de>
Subject: Re: [PATCH v3 0/8] arm64: rockchip: Initial GeekBox enablement
Date: Mon, 7 Mar 2016 18:15:53 +0100
Message-ID: <56DDB749.1020808@suse.de>
References: <1457294038-14243-1-git-send-email-afaerber@suse.de>
 <56DD7172.4000707@suse.de> <2714888.1DdqvJZ8cb@diego>
 <56DD7593.5060003@suse.de> <56DD8176.2080603@st.com>
 <56DD8FBE.9010200@suse.de> <56DD99A4.5030004@st.com>
 <56DDA26C.3050301@suse.de> <56DDA3D5.3090209@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Gabriel Fernandez <gabriel.fernandez@linaro.org>,
	=?UTF-8?Q?Heiko_St=c3=bcbner?= <heiko@sntech.de>,
	linux-rockchip@lists.infradead.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org,
	LAKML <linux-arm-kernel@lists.infradead.org>,
	Alexandre TORGUE <alexandre.torgue@st.com>,
	Fabrice GASNIER <fabrice.gasnier@st.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:33747 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753377AbcCGRP4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2016 12:15:56 -0500
In-Reply-To: <56DDA3D5.3090209@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 07.03.2016 um 16:52 schrieb Giuseppe CAVALLARO:
> On 3/7/2016 4:46 PM, Andreas F=E4rber wrote:
>> Am 07.03.2016 um 16:09 schrieb Giuseppe CAVALLARO:
>>> On 3/7/2016 3:27 PM, Andreas F=E4rber wrote:
>>>> Indeed, reverting Gabriel's commit fixes the observed error messag=
es
>> [...]
>>>> However, I am unable to ping any hosts on the network now.
>>>
>>> hmm, this could be another problem. I wonder if you can
>>> check which recent patch is introducing the problem on ARM64.
>>> For example if this depends on Oct_2015 update.
>>
>> I've had success reverting drivers/net/ethernet/stmicro/ up to and
>> including "stmmac: first frame prep at the end of xmit routine", i.e=
=2E
>> top 7 commits.
>=20
> Andreas, I will check it and let you know asap.

I verified that it's just these two commits that I need to revert:

"stmmac: Fix 'eth0: No PHY found' regression"
"stmmac: first frame prep at the end of xmit routine"

Those in between don't cause conflicts and seem to work okay.

Andreas

--=20
SUSE Linux GmbH, Maxfeldstr. 5, 90409 N=FCrnberg, Germany
GF: Felix Imend=F6rffer, Jane Smithard, Graham Norton; HRB 21284 (AG N=FC=
rnberg)
