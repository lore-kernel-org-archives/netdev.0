From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: [PATCH] net: wireless: ath: ath10k: remove unnecessary code
Date: Tue, 9 May 2017 12:20:40 +0000
Message-ID: <87wp9qz0fd.fsf@kamboji.qca.qualcomm.com>
References: <20170509042159.GA19727@embeddedgus>
        <87lgq6387s.fsf@kamboji.qca.qualcomm.com>
        <76408651-07c6-fe31-863f-e1cb73b49663@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "Gustavo A. R. Silva" <garsilva@embeddedor.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "ath10k@lists.infradead.org" <ath10k@lists.infradead.org>
To: Arend Van Spriel <arend.vanspriel@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <76408651-07c6-fe31-863f-e1cb73b49663@broadcom.com> (Arend Van
        Spriel's message of "Tue, 9 May 2017 14:07:57 +0200")
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arend Van Spriel <arend.vanspriel@broadcom.com> writes:

> On 9-5-2017 7:33, Kalle Valo wrote:
>> "Gustavo A. R. Silva" <garsilva@embeddedor.com> writes:
>>=20
>>> The name of an array used by itself will always return the array's addr=
ess.
>>> So these tests will always evaluate as false and therefore the _return_
>>> will never be executed.
>>>
>>> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
>>=20
>> I don't understand the commit log, especially what does "The name of an
>> array used by itself" mean?
>
> The array fields in struct wmi_start_scan_arg that are checked here are
> fixed size arrays so they can never be NULL.
>
> Maybe that helps rephrasing this commit message.

Much much better, thanks!

--=20
Kalle Valo=
