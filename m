From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [Updated patch] Re: [PATCH] igb: fix kexec with igb
Date: Tue, 31 Mar 2009 12:51:49 -0700
Message-ID: <9929d2390903311251n43988214y6f1b2defa87e1a48@mail.gmail.com>
References: <49B1F934.5050006@kernel.org> <200903291319.15269.rjw@sisk.pl>
	 <9929d2390903301436q1cd96e05x47d60cff72e41b4d@mail.gmail.com>
	 <200903302339.33781.rjw@sisk.pl>
	 <EA929A9653AAE14F841771FB1DE5A1365F71995716@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, Yinghai Lu <yinghai@kernel.org>,
	Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	David Miller <davem@davemloft.net>,
	Ingo Molnar <mingo@elte.hu>,
	Andrew Morton <akpm@linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:13285 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752235AbZCaTvw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 15:51:52 -0400
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A1365F71995716@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 31, 2009 at 12:14 PM, Tantilov, Emil S
<emil.s.tantilov@intel.com> wrote:
>
> The patch checks out. I tested suspend/resume (including WOL) and kex=
ec. There is only a small issue with warning on compile when CONFIG_PM =
is disabled:
>
> diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
> index 13fe162..0a4f8f4 100644
> --- a/drivers/net/igb/igb_main.c
> +++ b/drivers/net/igb/igb_main.c
> @@ -135,8 +135,8 @@ static inline int igb_set_vf_rlpml(struct igb_ada=
pter *, int, int);
> =C2=A0static int igb_set_vf_mac(struct igb_adapter *adapter, int, uns=
igned char *);
> =C2=A0static void igb_restore_vf_multicasts(struct igb_adapter *adapt=
er);
>
> -static int igb_suspend(struct pci_dev *, pm_message_t);
> =C2=A0#ifdef CONFIG_PM
> +static int igb_suspend(struct pci_dev *, pm_message_t);
> =C2=A0static int igb_resume(struct pci_dev *);
> =C2=A0#endif
> =C2=A0static void igb_shutdown(struct pci_dev *);
>
> Thanks,
> Emil
>

Rafael - Based on Emil's testing, I will modify the patch with Emil's
suggestion and push to Dave, ok?

--=20
Cheers,
Jeff
