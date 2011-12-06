From: Anca Emanuel <anca.emanuel@gmail.com>
Subject: Re: v6: faster tree-based sysctl implementation
Date: Wed, 7 Dec 2011 01:42:58 +0200
Message-ID: <CAJL_dMtvgnZHH0uLE3j7Mg2Xqwt2rd90Uy0pUxm6muPmjFbkQg@mail.gmail.com>
References: <CAPLs8y9omncDbLE_KNoKOLLbfwHjWYUJX_i7cC4bLiJsyPbtZQ@mail.gmail.com>
	<CAJL_dMtgP+BqFn3aGVBbGDJ+kMyGiEC_NmDURzh4mU=Jo=qZVA@mail.gmail.com>
	<CAPLs8y8vhioqc3CPrD7ugmVkR2DjKWNm8+T5j9QQnrxi=BgvdA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Eric W . Biederman" <ebiederm@xmission.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Octavian Purdila <tavi@cs.pub.ro>,
	"David S . Miller" <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Damien Millescamps <damien.millescamps@6wind.com>
To: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:61107 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752788Ab1LFXm7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 18:42:59 -0500
In-Reply-To: <CAPLs8y8vhioqc3CPrD7ugmVkR2DjKWNm8+T5j9QQnrxi=BgvdA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 6, 2011 at 4:33 PM, Lucian Adrian Grijincu
<lucian.grijincu@gmail.com> wrote:
> Sysctl uses a slow algorithm: O(N^2) for insertions, O(N) for lookup,
> with a relatively big constant.
> The performance is acceptable when N is small, but sometimes it can
> grow to bigger values.
> One case where N can grow to very large values is when you add network
> interfaces.
>
[snip]
>
> This algorithm is O(N * logN) for insert and O(logN) for lookup.
>
>
>> You add more code. This is not good. If you reduce the code, then it
>> will be interesting.
>
> Thank you. I know that, but it's easier said than done. I'd welcome
> some feedback in what could be simplified in my patches :)

>From an "airplane view" you can make the algorithms generic, and find
other places in kernel that can use them.
If you do that, I am sure you will get the attention.
