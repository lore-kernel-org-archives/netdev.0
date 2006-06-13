From: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>
Subject: Re: [PATCH 2.6.17-rc6] Remove Prism II support from Orinoco
Date: Mon, 12 Jun 2006 17:10:57 -0700
Message-ID: <4807377b0606121710j5be6ce0fhac71b69bf4dce2c2@mail.gmail.com>
References: <20060610175010.GA4617@divinity> <20060610180850.GP7420@redhat.com>
	 <20060611222719.GA13139@redhat.com>
	 <20060611224054.GB13139@redhat.com> <20060611224954.GA2880@divinity>
	 <20060612152434.GA14851@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Faidon Liambotis" <faidon@cube.gr>,
	"Dave Jones" <davej@redhat.com>, netdev@vger.kernel.org,
	proski@gnu.org, hermes@gibson.dropbear.id.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:50169 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S932473AbWFMAK7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jun 2006 20:10:59 -0400
Received: by nf-out-0910.google.com with SMTP id x30so61343nfb
        for <netdev@vger.kernel.org>; Mon, 12 Jun 2006 17:10:57 -0700 (PDT)
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060612152434.GA14851@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/12/06, John W. Linville <linville@tuxdriver.com> wrote:
> On Mon, Jun 12, 2006 at 01:49:54AM +0300, Faidon Liambotis wrote:
>
> > Having two drivers supporting the same set of hardware seems pretty
> > pointless to me. Plus, it confuses hotplugging/automatic detection.
>
> This subject comes-up from time to time.  In fact, I'm pretty sure
> it came-up very recently w.r.t. orinoco and hostap.
>
> The consensus seems to be that drivers should have IDs for all devices
> they support, even if that means that some devices are supported by
> multiple drivers.  This leaves the choice of which driver to use in
> the hands of the user and/or distro.

my problem is that for my prism 2 adapter both drivers are loaded at
which point neither of them works.  I'm running FC5, and i have to
keep removing the orinoco*.ko files to keep them from loading, so I'm
all for this patch.

Jesse
