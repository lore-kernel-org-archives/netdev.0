From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] rtlwifi: use s8 instead of char
Date: Thu, 16 Jun 2016 16:02:38 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D5F4DA915@AcuExch.aculab.com>
References: <20160615210318.4130648-1-arnd@arndb.de>
 <wrfjbn32taxw.fsf@redhat.com> <5245411.kmNEkqpVVS@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Kalle Valo <kvalo@codeaurora.org>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: 'Arnd Bergmann' <arnd@arndb.de>,
	Jes Sorensen <Jes.Sorensen@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5245411.kmNEkqpVVS@wuerfel>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann
> On Wednesday, June 15, 2016 5:10:51 PM CEST Jes Sorensen wrote:
> >
> > Arnd,
> >
> > rtlwifi and rtl8xxxu are two distinct drivers managed by different
> > people. I'd be really nice if you could split this into a per driver
> > patch.
> >
> > That said, the use of char in rtl8xxxu is all as a flag indicator, so I
> > don't think the s/char/s8/ conversion is justified. I used char rather
> > than ugly bool to reduce the size of the struct.
> 
> Makes sense, I'll resend without that change. If anything, the flag
> should become u8, not s8 anyway.

Does bool:8 work ?

	David
