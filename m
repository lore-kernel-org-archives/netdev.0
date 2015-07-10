From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH 03/11] soc/fsl: Introduce the DPAA BMan portal driver
Date: Fri, 10 Jul 2015 18:47:16 +0200
Message-ID: <1436546836.20619.231.camel@tiscali.nl>
References: <1436473322-21247-1-git-send-email-Roy.Pledge@freescale.com>
	 <1436473322-21247-4-git-send-email-Roy.Pledge@freescale.com>
	 <1436535163.20619.216.camel@tiscali.nl>
	 <BN3PR0301MB1267A318EF9DB3C193DA9FA08C9F0@BN3PR0301MB1267.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	Scott Wood <scottwood@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Roy Pledge <roy.pledge@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BN3PR0301MB1267A318EF9DB3C193DA9FA08C9F0@BN3PR0301MB1267.namprd03.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Roy,

On vr, 2015-07-10 at 15:19 +0000, Roy Pledge wrote:
> Thanks you for your valuable feedback so far.

You're welcome. Please note that I just scan for, well, common build
issues. Ie, stuff that requires no domain specific knowledge.

> Let me try to address a general issue you mention below: unused 
> exported APIs.

Good timing. I was pondering how to handle 04/11, a big patch that
exports 79 (!) symbols. Many of those appear to have no users.

> The QMan and BMan drivers provide a base layer for other blocks built 
> on top of them, for instance an Ethernet Driver, an Encrypt/Decrypt 
> Engine,  a pattern matcher, a compress/decompress engine, etc...
> Some of these drivers will be presented for review in the near future, 
> but in order to try and layer the review/up streaming process we're 
> presenting each layer as independently as possible.
> If you really were to start dissecting which APIs are called you would 
> come to a very small set of pieces that merely initialize the hardware 
> but don't provide any opportunity for other users to invoke that HW. 
> 
> I hope that this helps you understand our goals in trying to upstream 
> these drivers.

At the end of the day, what matters is what the people that need to sign
off on these drivers (ppc? netdev?) are comfortable with. I know that
some maintainers won't even bother looking at code that has no callers.

In the mean time I'll skip the exports for the remainder of this series.

Thanks,


Paul Bolle
