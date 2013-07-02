From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH] drivers/ptp/Kconfig: add "depends on HAS_IOMEM" for 'PTP_1588_CLOCK_PCH'
Date: Tue, 02 Jul 2013 08:57:24 +0800
Message-ID: <51D22574.60401@asianux.com>
References: <51CB8CB7.6010006@asianux.com> <20130628.212311.1348427834856668120.davem@davemloft.net> <51D0DCB5.5060106@asianux.com> <51D11661.7040604@nod.at> <51D11D14.8000706@asianux.com> <51D122F0.1000204@nod.at> <51D12545.4000108@asianux.com> <CAMuHMdXnO8-9riLcFLQfMoWJRgy7gtQJdKkHZNR0D5eaM4=oxQ@mail.gmail.com> <51D1341E.6090908@asianux.com> <CAMuHMdVkVQvo0vAyHc8Cny7eCtWwcZGBWqK3dBS+ZEwNzhtHjw@mail.gmail.com> <51D1642F.9010303@nod.at> <CAMuHMdXSExr0w-occZyHgj8o87q4_+BRH7e-bktMRfqfTqk8vQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: Richard Weinberger <richard@nod.at>,
	David Miller <davem@davemloft.net>,
	Richard Cochran <richardcochran@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:43446 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755710Ab3GBA6R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jul 2013 20:58:17 -0400
In-Reply-To: <CAMuHMdXSExr0w-occZyHgj8o87q4_+BRH7e-bktMRfqfTqk8vQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/01/2013 07:19 PM, Geert Uytterhoeven wrote:
> On Mon, Jul 1, 2013 at 1:12 PM, Richard Weinberger <richard@nod.at> wrote:
>> > Am 01.07.2013 09:56, schrieb Geert Uytterhoeven:
>>> >> If we follow your reasoning, we can add dummy variants of all hardware support
>>> >> that lives in arch/*/include/asm to asm-generic, so everything would compile
>>> >> for all platforms. But that's now what we want.
>> >
>> > I hope you meant *not* want?
> Sorry, s/now/not/

I can understand your feelings, I also can understand if none of my
patches for 'asm-generic' will be applied.

Most of patches for 'asm-generic' should be for 'important' (e.g. duty
definition: whether should support 'COMPILE_TEST', what's the meaning of
'generic').

But this kind of patches are not 'emergent', they need be given more
considerations (they are not for applying, the are for thinking).

For duty definition, it is not for what we want to do, it is for what we
should do (or what we have to do).


At last, I will send related patches for 'COMPILE_TEST' (I can
understand if not applied, or no response). And also should send another
patch for HAS_IOMEM about ptp driver (also cc to you all).

Thanks.
-- 
Chen Gang
