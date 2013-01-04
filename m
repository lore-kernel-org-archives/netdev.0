From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: Re: [PATCH -v2 19/26] batman-adv: rename random32() to prandom_u32()
Date: Fri, 4 Jan 2013 22:50:41 +0900
Message-ID: <CAC5umyhLB++mh=-pFRzhD-YxZH2RwC5ED4g8mYxS5pYGcbxsvw@mail.gmail.com>
References: <1357215562-6288-1-git-send-email-akinobu.mita@gmail.com>
	<1357215562-6288-20-git-send-email-akinobu.mita@gmail.com>
	<20130104021252.GE27589@ritirata.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Simon Wunderlich <siwu@hrz.tu-chemnitz.de>,
	b.a.t.m.a.n@lists.open-mesh.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Antonio Quartulli <ordex@autistici.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130104021252.GE27589@ritirata.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2013/1/4 Antonio Quartulli <ordex@autistici.org>:
> On Thu, Jan 03, 2013 at 09:19:15PM +0900, Akinobu Mita wrote:
>> Use more preferable function name which implies using a pseudo-random
>> number generator.
>>
>> Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
>> Acked-by: Antonio Quartulli <ordex@autistici.org>
>> Cc: Marek Lindner <lindner_marek@yahoo.de>
>> Cc: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
>> Cc: Antonio Quartulli <ordex@autistici.org>
>> Cc: b.a.t.m.a.n@lists.open-mesh.org
>> Cc: "David S. Miller" <davem@davemloft.net>
>> Cc: netdev@vger.kernel.org
>> ---
>
> Hello Akinobu,
>
> as you can see in <201301021952.49979.lindner_marek@yahoo.de>, Marek Lindner
> already applied this change onto our tree. You didn't need to resend this patch
> to netdev, it will be sent by us through a future pull request.

Yes. I read Marek's email. But I included it in v2 again in order not
to break the build. Because it doesn't show up the latest linux-next yet
and the last patch 26/26 removes random32() and srandom32().

But I should have mentioned it and trimmed the Cc list.
Sorry for the confusion.
