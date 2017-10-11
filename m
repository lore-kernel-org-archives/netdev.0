From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: [PATCH] wcn36xx: Remove unnecessary rcu_read_unlock in
 wcn36xx_bss_info_changed
Date: Wed, 11 Oct 2017 08:28:42 +0000
Message-ID: <87wp42qe9y.fsf@kamboji.qca.qualcomm.com>
References: <1507467969-24016-1-git-send-email-baijiaju1990@163.com>
        <20171011065445.GP1165@minitux>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Jia-Ju Bai <baijiaju1990@163.com>,
        "k.eugene.e@gmail.com" <k.eugene.e@gmail.com>,
        "wcn36xx@lists.infradead.org" <wcn36xx@lists.infradead.org>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Bjorn Andersson <bjorn.andersson@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171011065445.GP1165@minitux> (Bjorn Andersson's message of
        "Tue, 10 Oct 2017 23:54:45 -0700")
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bjorn Andersson <bjorn.andersson@linaro.org> writes:

> On Sun 08 Oct 06:06 PDT 2017, Jia-Ju Bai wrote:
>
>> No rcu_read_lock is called, but rcu_read_unlock is still called.
>> Thus rcu_read_unlock should be removed.
>>=20
>
> Thanks, not sure how I could miss that one. Kalle can you please include
> this in a v4.14-rc pull request?
>
>
> :
>
> Fixes: 39efc7cc7ccf ("wcn36xx: Introduce mutual exclusion of fw configura=
tion")
>
>> Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
>
> Acked-by: Bjorn Andersson <bjorn.andersson@linaro.org>

Ok, I'll queue this to 4.14.

--=20
Kalle Valo=
