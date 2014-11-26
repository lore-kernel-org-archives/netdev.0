From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch net-next v3 04/17] net: introduce generic switch devices
 support
Date: Wed, 26 Nov 2014 16:08:59 +0000
Message-ID: <20141126160859.GB13786@casper.infradead.org>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us>
 <1416911328-10979-5-git-send-email-jiri@resnulli.us>
 <5474A567.4040401@mojatatu.com>
 <20141125164954.GJ1971@nanopsycho.orion>
 <5474B795.3080204@mojatatu.com>
 <20141125215402.GA3912@casper.infradead.org>
 <54754A10.6020601@mojatatu.com>
 <CAE4R7bCYwWt5cem5_v8Y0jOSz5ER5_33bMRE2xkTPOqYvM6dUg@mail.gmail.com>
 <5475BB53.3070200@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Scott Feldman <sfeldma@gmail.com>, Jiri Pirko <jiri@resnulli.us>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"dborkman@redhat.com" <dborkman@redhat.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"jesse@nicira.com" <jesse@nicira.com>,
	"pshelar@nicira.com" <pshelar@nicira.com>,
	"azhou@nicira.com" <azhou@nicira.com>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	John Linville <linville@tux
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:33426 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752224AbaKZQJG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 11:09:06 -0500
Content-Disposition: inline
In-Reply-To: <5475BB53.3070200@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/26/14 at 06:36am, Jamal Hadi Salim wrote:
> On 11/25/14 23:18, Scott Feldman wrote:
> >On Tue, Nov 25, 2014 at 5:33 PM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> 
> >
> >You have a pointer to the kernel driver for that HW?
> 
> I wasnt sure if that was a passive aggressive move there to
> question what i am claiming?(Only Canadians are allowed to be
> passive aggressive Scott). To answer your question, no
> code currently littered with vendor SDK unfortunately (as you
> would know!).
> But hopefully if we get these changes in correctly it would
> not be hard to show the driver working fully in the kernel.
> There are definetely a few other pieces of hardware that are
> making me come back here and invest time and effort in these
> long discussions.
> 
> >Can you show how
> >you're using Linux tc netlink msg in kernel to program HW?  I'd like
> >to see the in-kernel API.
> >
> 
> Lets do the L2/port thing first. But yes, I am using Linux tc in
> kernel.

Jamal,

What is irriating in this context is that you are pushing back on
Jiri and others while referring to properitary and closed code which
you are unwilling or unable to share. I don't see this as being
passive aggressive, everybody is treated the same way in this regard.

It is exactly the point of this API and related discussions to
decouple the control plane (tc) from any vendor specifics while
allowing them to innovate, compete, and solve different use cases.

I think it's absolutely the right thing to write the API against
code that is public, which in this case is rocker and the existing
in-kernel NIC drivers.
