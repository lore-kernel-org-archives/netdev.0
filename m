From: Julien Grall <julien.grall@citrix.com>
Subject: Re: [Xen-devel] [PATCH 4/8] xen: Use the correctly the Xen memory
 terminologies
Date: Wed, 29 Jul 2015 12:27:07 +0100
Message-ID: <55B8B88B.2070400@citrix.com>
References: <1438095769-2560-1-git-send-email-julien.grall@citrix.com>
	<1438095769-2560-5-git-send-email-julien.grall@citrix.com>
 <4EE5B48738DDED408878C97C8E050A8B1D7DDBB5@SJEXCHMB05.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: "linux-fbdev@vger.kernel.org" <linux-fbdev@vger.kernel.org>,
	"H. Peter Anvin" <hpa@zytor.com>, Jiri Slaby <jslaby@suse.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Russell King <linux@arm.linux.org.uk>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	Tomi Valkeinen <tomi.valkeinen@ti.com>,
	"x86@kernel.org" <x86@kernel.org>, Ingo Molnar <mingo@redhat.com>,
	"linux-input@vger.kernel.org" <linux-input@vger.kernel.org>,
	Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>,
	"ian.campbell@citrix.com" <ian.campbell@citrix.com>,
	"stefano.stabellini@eu.citrix.com" <stefano.stabellini@eu.citrix.com>,
	"James E.J. Bottomley" <JBottomley@odin.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Juergen Gross <jgross@suse.com>,
	"Wei Liu" <wei.liu2@citrix.com>,
	Greg Kroah-Hartman <gregkh@lin
To: "Chris (Christopher) Brand" <chris.brand@broadcom.com>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4EE5B48738DDED408878C97C8E050A8B1D7DDBB5@SJEXCHMB05.corp.ad.broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Chris,

On 28/07/15 20:39, Chris (Christopher) Brand wrote:
>> Based on include/xen/mm.h [1], Linux is mistakenly using MFN when GFN is meant,
>> I suspect this is because the first support for Xen was for PV. This brough some
> Typo : "brought"
> Perhaps "resulted in" would be better ?
> 
>> misimplementation of helpers on ARM and make the developper confused the expected behavior.
> Typo: "developer".
> I'd also suggest "...and confused developers about the...".
> 
> [...]
> 
>> For clarity and avoid new confusion, replace any reference of mfn into gnf in any helpers used by PV drivers.
> Typo : "gfn"
> I'd suggest "...replace any reference to mfn with gfn..."
> 
> [...]

Thanks for telling me the typoes. I will fix it in the next version of
this series.

Regards,

-- 
Julien Grall
