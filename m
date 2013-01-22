From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH 16/20] drivers/net/wireless/p54: remove depends on CONFIG_EXPERIMENTAL
Date: Tue, 22 Jan 2013 10:40:12 -0800
Message-ID: <CAGXu5jJCQshUntUk7MeZds59B2fa54GnonOz28dM1x2spEEGDg@mail.gmail.com>
References: <1358879444-25834-1-git-send-email-keescook@chromium.org>
	<1358879444-25834-17-git-send-email-keescook@chromium.org>
	<201301221937.16916.chunkeey@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Kalle Valo <kvalo@qca.qualcomm.com>
To: Christian Lamparter <chunkeey@googlemail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201301221937.16916.chunkeey@googlemail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 22, 2013 at 10:37 AM, Christian Lamparter
<chunkeey@googlemail.com> wrote:
> Aren't these patches going through wireless-next
> or linux-next?

They can go however it makes things easiest. Greg has offered to carry
them in driver-core if Dave doesn't want to carry them in netdev.

-Kees

>
> On Tuesday, January 22, 2013 07:30:40 PM Kees Cook wrote:
>> The CONFIG_EXPERIMENTAL config item has not carried much meaning for a
>> while now and is almost always enabled by default. As agreed during the
>> Linux kernel summit, remove it from any "depends on" lines in Kconfigs.
>>
>> CC: Christian Lamparter <chunkeey@googlemail.com>
>> CC: "John W. Linville" <linville@tuxdriver.com>
>> Cc: "David S. Miller" <davem@davemloft.net>
>> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
>> Cc: NetDev <netdev@vger.kernel.org>
>> Signed-off-by: Kees Cook <keescook@chromium.org>
> Acked-by: Christian Lamparter <chunkeey@googlemail.com>
> [Also ACK the carl9170, if necessary]
>
> Regards,
>         Chr



--
Kees Cook
Chrome OS Security
