From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: use hardware buffer pool to allocate skb
Date: Wed, 15 Oct 2014 02:15:21 -0700
Message-ID: <1413364521.12304.43.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1413343571-33231-1-git-send-email-Jiafei.Pan@freescale.com>
	 <1413346503.17109.23.camel@edumazet-glaptop2.roam.corp.google.com>
	 <efb0b7f4955243fbab9b24e0c31ea806@BY2PR03MB524.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"jkosina@suse.cz" <jkosina@suse.cz>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"LeoLi@freescale.com" <LeoLi@freescale.com>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>
To: "Jiafei.Pan@freescale.com" <Jiafei.Pan@freescale.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <efb0b7f4955243fbab9b24e0c31ea806@BY2PR03MB524.namprd03.prod.outlook.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-10-15 at 05:43 +0000, Jiafei.Pan@freescale.com wrote:

> For my case, there are some shortcoming to use page frags. Firstly, I=
 have to
> modify each Ethernet drivers to support it especially I don=E2=80=99t=
 which vendor's
> driver the customer will use. Secondly, it is not enough only=20
> build skb by 'lock' pages, the buffer address comes from hardware blo=
ck and
> should be aligned to hardware block.

So you align to hardware block. What is the problem with this ?


