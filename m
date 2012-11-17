From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH] checkpatch: add double empty line check
Date: Sat, 17 Nov 2012 13:12:56 +0200
Message-ID: <1353150776.14327.13.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1353094919.14327.4.camel@lb-tlvb-eilong.il.broadcom.com>
 <alpine.DEB.2.00.1211161154280.2788@chino.kir.corp.google.com>
 <1353096274.14327.9.camel@lb-tlvb-eilong.il.broadcom.com>
 <1353113454.2512.21.camel@joe-AO722>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David Rientjes" <rientjes@google.com>,
	"Andy Whitcroft" <apw@canonical.com>, linux-kernel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: "Joe Perches" <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1353113454.2512.21.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-11-16 at 16:50 -0800, Joe Perches wrote:

Hi Joe, thanks for replying.

> On Fri, 2012-11-16 at 22:04 +0200, Eilon Greenstein wrote:
> > On Fri, 2012-11-16 at 11:55 -0800, David Rientjes wrote:
> > > On Fri, 16 Nov 2012, Eilon Greenstein wrote:

> > > This is fairly common in all the acpi code where variables declared in a 
> > > function are separated from the code in a function.
> > > 
> > 
> > Indeed, I see that you do use it in some functions.
> > 
> > Maybe we can limit it only to the networking tree (similar to the
> > networking comments style) or if the ACPI is the exception, we can apply
> > to all but ACPI.
> 
> I'm not sure this should be done.
> Double line spacing has some utility and
> is pretty common.

Since adding double empty line can cause a patch to be rejected, we
should have an easy way to catch it before submitting.

> Perhaps make this a --strict/CHK option
> and also perhaps make sure this isn't
> emitted on consecutive lines.

Indeed, CHK makes more sense. I wanted to have a warning per redundant
line, but since it can be annoying when adding 3 or more empty lines
intentionally, I will issue one comment for consecutive lines.

v2 is on its way.

Thanks,
Eilon
