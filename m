From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: Re: [PATCH] net: wireless: ath: ath10k: remove unnecessary code
Date: Tue, 09 May 2017 07:34:42 -0500
Message-ID: <20170509073442.Horde.Q8CbZi0XhNUcuRQ3NxtQfks@gator4166.hostgator.com>
References: <20170509042159.GA19727@embeddedgus>
 <87lgq6387s.fsf@kamboji.qca.qualcomm.com>
 <76408651-07c6-fe31-863f-e1cb73b49663@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"; DelSp="Yes"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Kalle Valo <kvalo@qca.qualcomm.com>,
 linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
 ath10k@lists.infradead.org
To: Arend Van Spriel <arend.vanspriel@broadcom.com>
Return-path: <ath10k-bounces+gldad-ath10k=m.gmane.org@lists.infradead.org>
In-Reply-To: <76408651-07c6-fe31-863f-e1cb73b49663@broadcom.com>
Content-Disposition: inline
List-Unsubscribe: <http://lists.infradead.org/mailman/options/ath10k>,
 <mailto:ath10k-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/ath10k/>
List-Post: <mailto:ath10k@lists.infradead.org>
List-Help: <mailto:ath10k-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/ath10k>,
 <mailto:ath10k-request@lists.infradead.org?subject=subscribe>
Sender: "ath10k" <ath10k-bounces@lists.infradead.org>
Errors-To: ath10k-bounces+gldad-ath10k=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hi Arend,

Quoting Arend Van Spriel <arend.vanspriel@broadcom.com>:

> On 9-5-2017 7:33, Kalle Valo wrote:
>> "Gustavo A. R. Silva" <garsilva@embeddedor.com> writes:
>>
>>> The name of an array used by itself will always return the array's address.
>>> So these tests will always evaluate as false and therefore the _return_
>>> will never be executed.
>>>
>>> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
>>
>> I don't understand the commit log, especially what does "The name of an
>> array used by itself" mean?
>
> The array fields in struct wmi_start_scan_arg that are checked here are
> fixed size arrays so they can never be NULL.
>
> Maybe that helps rephrasing this commit message.
>

Definitely. Thank you!
--
Gustavo A. R. Silva
