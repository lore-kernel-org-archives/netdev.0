From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] net: team: expose sysfs attributes for each team option
Date: Thu, 20 Nov 2014 16:05:23 +0000
Message-ID: <20141120160523.GB11458@casper.infradead.org>
References: <93856491220bda9aede41a9571fb1ac1.squirrel@www.codeaurora.org>
 <20141117130201.GB1872@nanopsycho.orion>
 <03067d01f18e264b30f86d0307d11b07.squirrel@www.codeaurora.org>
 <CAHA+R7OOnSfSP1uHrg=osH=+=sb-0Zj-=yYx8HXmpO95v+Dhyg@mail.gmail.com>
 <546CECAD.1040402@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cong Wang <cwang@twopensource.com>,
	Hamad Kadmany <hkadmany@codeaurora.org>,
	Jiri Pirko <jiri@resnulli.us>, netdev <netdev@vger.kernel.org>,
	Daniel Borkmann <dborkman@redhat.com>
To: Hamad Kadmany <hkadmany@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:50897 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751418AbaKTQF1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2014 11:05:27 -0500
Content-Disposition: inline
In-Reply-To: <546CECAD.1040402@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/19/14 at 08:17pm, Daniel Borkmann wrote:
> On 11/19/2014 07:45 PM, Cong Wang wrote:
> >On Wed, Nov 19, 2014 at 4:28 AM, Hamad Kadmany <hkadmany@codeaurora.org> wrote:
> >>On Mon, November 17, 2014 1:02 pm, Jiri Pirko wrote:
> >>>
> >>>Nak.
> >>>
> >>>I don't like this patch. The plan for team was keep things simple and to
> >>>have single userspace api using netlink, as that is the correct way to
> >>>deal with things. Sysfs for this use-case is not. Please, use netlink api.
> 
> +1
> 
> >>Using team driver requires using libnl3. In Android based platforms, libnl3
> >> is not supported, and libnl3 license poses constraints in Android's user-space.
> 
> Constraints?! libnl3 is LGPL ...

The behaviour on this particular topic is disappointing. Instead of
working with the community and using an existing library such as
libmnl or libnl Android chose to fork libnl3 and disregard the
community a couple of years ago.

The reasoning in this thread is the next episode of the same story.

Very disappointing.
