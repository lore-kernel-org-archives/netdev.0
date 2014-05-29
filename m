From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH v1 1/3] usb: gadget: NCM: RX function support multiple NDPs
Date: Thu, 29 May 2014 20:55:16 +0200
Message-ID: <87d2ewbejv.fsf@nemi.mork.no>
References: <jim_baxter@mentor.com>
	<1401383543-10181-1-git-send-email-jim_baxter@mentor.com>
	<1401383543-10181-2-git-send-email-jim_baxter@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Felipe Balbi <balbi@ti.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	<linux-usb@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Laight <David.Laight@ACULAB.COM>,
	<netdev@vger.kernel.org>
To: Jim Baxter <jim_baxter@mentor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1401383543-10181-2-git-send-email-jim_baxter@mentor.com> (Jim
	Baxter's message of "Thu, 29 May 2014 18:12:21 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jim Baxter <jim_baxter@mentor.com> writes:

> The NDP was ignoring the wNextNdpIndex in the NDP which
> means that NTBs containing multiple NDPs would have missed
> frames.

Well, just for the record: I believe this field was meant to be reserve=
d
and always 0 in the CDC NCM spec.  Table 3-3, describing 16bit NDPs,
says so.  But reading the spec now, I noticed that there is an
inconsistency between table 3-3 and table 3-4 describing 32bit NDPs.  I=
t
looks like the field is not reserved in the 32bit version.

I am pretty sure that is a specification error, but I guess it doesn't
harm to implement the support anyway.  And it paves the way for an MBIM
gadget :-)




Bj=C3=B8rn
