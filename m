From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>
Subject: Re: [PATCH] net/macb: fix sparse warning
Date: Thu, 5 Feb 2015 16:22:39 +0000
Message-ID: <CA+V-a8t+p70mjOY0cCnQ=JOPAFpRLxy9vjLQCT1N99iYNxsdSg@mail.gmail.com>
References: <1423150846-7027-1-git-send-email-prabhakar.csengg@gmail.com> <54D3951C.1080200@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54D3951C.1080200@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 5, 2015 at 4:06 PM, Nicolas Ferre <nicolas.ferre@atmel.com>=
 wrote:
> Le 05/02/2015 16:40, Lad Prabhakar a =C3=A9crit :
>> From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>
>>
>> this patch fixes following sparse warning:
>>
>> macb.c:2038:26: warning: symbol 'gem_ethtool_ops' was not declared. =
Should it be static?
>
> Well, actually this function doesn't need to be exported and indeed
> should be marked as static.
>
> I'm not against this patch, but removing the export macro and making =
it
> as static should do the trick even better.
>
Done!

[1] https://patchwork.kernel.org/patch/5785511/

Cheers,
--Prabhakar Lad
