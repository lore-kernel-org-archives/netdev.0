From: Tom Herbert <therbert@google.com>
Subject: Re: [RFC PATCH 0/5] net: low latency Ethernet device polling
Date: Wed, 27 Feb 2013 10:47:41 -0800
Message-ID: <CA+mtBx85G3qD2_QP709kOMERP9T8v1W+ZNj12qnZWg_kALQtLg@mail.gmail.com>
References: <20130227175549.10611.82188.stgit@gitlad.jf.intel.com>
	<20130227101354.15636ba5@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eliezer Tamir <eliezer.tamir@linux.jf.intel.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Dave Miller <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130227101354.15636ba5@nehalam.linuxnetplumber.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 27, 2013 at 10:13 AM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
>
> Have you looked at netmap? Seems like a cleaner user API for this.
>
That might be a bit orthogonal to this.  I believe the intent it to
allow spin polling from socket calls without API change.

>
> There is a version for Linux, but it needs work. My plan is to send it staging
> (after merge window reopens).
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
