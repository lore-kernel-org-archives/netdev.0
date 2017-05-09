From: Arend Van Spriel <arend.vanspriel@broadcom.com>
Subject: Re: [PATCH] net: wireless: ath: ath10k: remove unnecessary code
Date: Tue, 9 May 2017 14:07:57 +0200
Message-ID: <76408651-07c6-fe31-863f-e1cb73b49663@broadcom.com>
References: <20170509042159.GA19727@embeddedgus>
 <87lgq6387s.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "ath10k@lists.infradead.org" <ath10k@lists.infradead.org>
To: Kalle Valo <kvalo@qca.qualcomm.com>,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87lgq6387s.fsf@kamboji.qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9-5-2017 7:33, Kalle Valo wrote:
> "Gustavo A. R. Silva" <garsilva@embeddedor.com> writes:
> 
>> The name of an array used by itself will always return the array's address.
>> So these tests will always evaluate as false and therefore the _return_
>> will never be executed.
>>
>> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
> 
> I don't understand the commit log, especially what does "The name of an
> array used by itself" mean?

The array fields in struct wmi_start_scan_arg that are checked here are
fixed size arrays so they can never be NULL.

Maybe that helps rephrasing this commit message.

Regards,
Arend
