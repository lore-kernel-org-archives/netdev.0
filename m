From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH] b43: fix memory leak
Date: Thu, 18 Feb 2016 14:40:20 +0100
Message-ID: <CACna6rztbZ5P4RborXrTdLJDEmQyGNOExNvAmWcxZG83stS2bg@mail.gmail.com>
References: <1455798876-32186-1-git-send-email-sudipm.mukherjee@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kalle Valo <kvalo@codeaurora.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	b43-dev <b43-dev@lists.infradead.org>
To: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455798876-32186-1-git-send-email-sudipm.mukherjee@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 18 February 2016 at 13:34, Sudip Mukherjee
<sudipm.mukherjee@gmail.com> wrote:
> From: Sudip Mukherjee <sudip@vectorindia.org>
>
> On error we jumped to the label bcma_out and returned the error code but
> we missed freeing dev.

What if b43_one_core_attach fails? Won't we miss kfree then as well?
Shouldn't you simply improve error path and maybe use an additional
label? Also may we be missing a proper free in b43_bcma_remove as
well?

Your patch subject could also be a bit more descriptive (e.g. what
memory leak exactly is it).
