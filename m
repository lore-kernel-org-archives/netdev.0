From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH] pch_can: fix error passive level test
Date: Mon, 12 Dec 2011 10:31:30 +0100
Message-ID: <4EE5C9F2.7050502@grandegger.com>
References: <1323674180-16916-1-git-send-email-xi.wang@gmail.com> <4EE5B5D9.3030702@grandegger.com> <4EE5C6A7.1070506@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Xi Wang <xi.wang@gmail.com>,
	Masayuki Ohtake <masa-korg@dsn.okisemi.com>,
	Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <4EE5C6A7.1070506@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/12/2011 10:17 AM, Marc Kleine-Budde wrote:
> On 12/12/2011 09:05 AM, Wolfgang Grandegger wrote:
>> On 12/12/2011 08:16 AM, Xi Wang wrote:
>>> The test (((errc & PCH_REC) >> 8) > 127) would always be false because
>>> the receive error counter ((errc & PCH_REC) >> 8) is at most 127, where
>>> PCH_REC is defined as 0x7f00.  To test whether the receive error counter
>>> has reached the error passive level, the RP bit (15) should be used.
>>>
>>> Signed-off-by: Xi Wang <xi.wang@gmail.com>
>>
>> Acked-by: Wolfgang Grandegger <wg@grandegger.com>
> 
> Is this patch a candidate for stable?

You mean for the "net" branch? Yes, I think so.

Wolfgang.
