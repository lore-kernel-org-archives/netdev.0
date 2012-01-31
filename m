From: "devendra.aaru" <devendra.aaru@gmail.com>
Subject: Re: [PATCH 1/1] wireless: remove return in _rtl_pci_switch_clk_req
Date: Tue, 31 Jan 2012 01:22:22 -0500
Message-ID: <CAHdPZaPFq0eB2Y7zogr_xh+Ct0Ot4S+sU9RQSDquo5_Z=C+R8Q@mail.gmail.com>
References: <1327927591-28070-1-git-send-email-devendra.aaru@gmail.com>
	<4F27294D.30302@lwfinger.net>
	<1327967103.4230.7.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	chaoming_li@realsil.com.cn, linville@tuxdriver.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1327967103.4230.7.camel@joe2Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 30, 2012 at 6:45 PM, Joe Perches <joe@perches.com> wrote:
> On Mon, 2012-01-30 at 17:35 -0600, Larry Finger wrote:
>> The patch is OK, but the patch subject is bad. You should have "[PAT=
CH]
>> rtlwifi:...". Your patch is for rtlwifi, not wireless.
>
Will post a new patch, Thanks !!
> Hi Devendra.
>
> A reasonable rule of thumb is use the deepest directory
> path basename you can to prefix the patch.
> Something like:
>
> [PATCH] $(basename $(dirname $file)): terse description
>
> If you are patching drivers/net/ethernet/realtek/apt.c
> this becomes:
>
> [PATCH] realtek: terse description
>
> There are some exceptions though. =A0One of them
> is if the patch is in staging, prefix with
> [PATCH] staging: $(basename $(dirname $file)): description
>
> cheers, Joe
>
Thanks a lot Joe, will follow your suggestions :).

Devendra.
