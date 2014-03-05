From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCHv3 net-next 00/31] Misc. fixes for cxgb4 and iw_cxgb4
Date: Wed, 5 Mar 2014 11:15:33 -0800
Message-ID: <9E6E5D92-7F25-49A3-BEB5-424CCE2F725D@chelsio.com>
References: <1393936917-25847-1-git-send-email-hariprasad@chelsio.com> <20140304.132226.75524344104026791.davem@davemloft.net> <20140305053024.GA23862@hariprasad-pc>
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-rdma@vger.kernel.org, roland@purestorage.com,
	kumaras@chelsio.com, dm@chelsio.com, swise@opengridcomputing.com,
	santosh@chelsio.com, nirranjan@chelsio.com
To: Hariprasad S <hariprasad@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:52989
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752755AbaCETPq convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Mar 2014 14:15:46 -0500
In-Reply-To: <20140305053024.GA23862@hariprasad-pc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  Yes, thanks mightily for your help and advice and sorry for the size =
of the updates.  Hari has taken on the very difficult task of synchroni=
zing our out-of-kernel development branch with the in-kernel code.  The=
se two code bases have drifted apart quite a bit because of the difficu=
lty of translating our out-of-kernel changes into the in-kernel driver =
which uses completely different symbolic register constants.  This has =
led many of us to defer propagating our out-of-kernel work into the in-=
kernel driver =97 partly because of the difficulty and party because of=
 the error prone nature of the effort: there are many symbolic register=
 constants which have the exact same name but have completely different=
 values which has tripped us up at least twice, introducing bugs into t=
he kernel.org driver.  If there=92s ever an opportunity to revisit the =
decision to have us use these different constants we would be Very Exci=
ted =85 :-)

Casey



On Mar 4, 2014, at 9:30 PM, Hariprasad S <hariprasad@chelsio.com> wrote=
:

> On Tue, Mar 04, 2014 at 13:22:26 -0500, David Miller wrote:
>>=20
>> BTW, if you're frustrated from having to send these patches so many
>> times because of changes being requested, this is the main reason
>> why you shouldn't queue up such enormous numbers of patches at one
>> time.
>>=20
>> Please try to keep your future submissions sizes more reasonable,
>> perhaps ~10 patches or so at most.
>>=20
>> Thanks.
>=20
> Sure, thanks for the suggestion.
> I will just re-post the revert patch on cxgb4 now, part of this serie=
s, which is=20
> causing regression.
> And, I will split the rest of patch-series into 8-10 patches and re-s=
ubmit.
>=20
>=20
> Thanks for the review comments!
> -Hari.
