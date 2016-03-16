From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next] vxlan: fix too large pskb_may_pull with remote
 checksum
Date: Wed, 16 Mar 2016 18:13:29 +0100
Message-ID: <20160316181329.55736b7f@griffin>
References: <fcf7ae744d2ab9fa8e560c37f50fc3f80ff20aa8.1458146074.git.jbenc@redhat.com>
	<CALx6S37=BFPfFB5Jwug5VeNJG2qtmVsRxCq-sW=q1knz73ZwhA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56604 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932369AbcCPRNc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Mar 2016 13:13:32 -0400
In-Reply-To: <CALx6S37=BFPfFB5Jwug5VeNJG2qtmVsRxCq-sW=q1knz73ZwhA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 16 Mar 2016 10:09:38 -0700, Tom Herbert wrote:
> On Wed, Mar 16, 2016 at 9:35 AM, Jiri Benc <jbenc@redhat.com> wrote:
> > The vxlan header is pulled at this point, don't include it again in the
> > calculation.
> >
> Hmm, I think I missing something obvious. Where was the pull of the
> vxlan header done?

In iptunnel_pull_header. Sorry, should have mentioned it.

 Jiri
