From: Michael Chan <mchan@broadcom.com>
Subject: Re: [PATCH] net-tg3: Initialize REG_BASE_ADDR at PCI config offset
 120 to 0
Date: Mon, 9 Dec 2013 13:07:33 -0800
Message-ID: <1386623253.1752.6.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <1386614601-9453-1-git-send-email-natg@google.com>
	 <1386615608.1752.4.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	 <CAGmqidkxoi9EEe0uC18QQUXwjFP1e_1MXL7VPk+NtU-Ta6FGUg@mail.gmail.com>
	 <52A633B4.9000307@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="cp1252"
Content-Transfer-Encoding: 7bit
Cc: Natarajan Gurumoorthy <natg@google.com>, <nsujir@broadcom.com>,
	<netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52A633B4.9000307@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-12-10 at 00:18 +0300, Sergei Shtylyov wrote: 
> >        We had crashes when the PCI config space got scanned via
> > /sys/devices/pcixxxx/....../config.
> 
> > I agree that this fix will not help if the scan happens before the tg3
> > driver gets loaded.
> 
>     Then perhaps a better place for such fixup would be a PCI quirk?
> 
Yes, I agree.  Thanks.
