From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [Linux 4.2-rc8+...v4.3-rc2] REGRESSION: ppp: circular locking
 dependency detected: [pppd] ppp_dev_uninit() | rtnl_lock()
Date: Thu, 24 Sep 2015 13:03:17 +0200
Message-ID: <20150924110317.GF2869@alphalink.fr>
References: <CA+icZUXjsqw-C7mNHRYzha+1efjm3pT-eoU0wb5KhOtEkroF8Q@mail.gmail.com>
 <20150923103803.GC2869@alphalink.fr>
 <CA+icZUXwOa0c9A8dUkykgqh-Ctnhw-YhhGsmEPtm50zdVsTtXA@mail.gmail.com>
 <CA+icZUU0rUJZRb4R+F1N98hbfb0rbmbZ0=Jf60zb30SQHKi1Ug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Sedat Dilek <sedat.dilek@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:40362 "EHLO
	mail-2-cbv2.admin.alphalink.fr" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752165AbbIXLD1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 07:03:27 -0400
Content-Disposition: inline
In-Reply-To: <CA+icZUU0rUJZRb4R+F1N98hbfb0rbmbZ0=Jf60zb30SQHKi1Ug@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 23, 2015 at 11:21:50PM +0200, Sedat Dilek wrote:
> On Wed, Sep 23, 2015 at 10:46 PM, Sedat Dilek <sedat.dilek@gmail.com> wrote:
> > On Wed, Sep 23, 2015 at 12:38 PM, Guillaume Nault <g.nault@alphalink.fr> wrote:
> > Do you mind to send a proper patch with subject-line and commit-message?
> > Can you embed the Fixes-tag and give credits like Reported-by/Tested-by?
>
I've just sent the patch to netdev.

> Do not forget CC-stable Tag, too.
> 
>      Cc: stable@vger.kernel.org# v4.2+
>
Well, that's not how it works for netdev. DaveM handles stable
submissions on his own.
