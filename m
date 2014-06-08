From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH iproute2 v3] bridge: Add master device name to bridge
 fdb show
Date: Sun, 08 Jun 2014 11:24:13 -0400
Message-ID: <5394801D.6080704@mojatatu.com>
References: <1402205022-7083-1-git-send-email-roopa@cumulusnetworks.com> <539447F6.9040906@mojatatu.com> <539476D7.8020300@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, stephen@networkplumber.org,
	netdev@vger.kernel.org, wkok@cumulusnetworks.com,
	sfeldma@cumulusnetworks.com, shm@cumulusnetworks.com,
	Vlad Yasevich <vyasevic@redhat.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:61840 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753325AbaFHPYS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Jun 2014 11:24:18 -0400
Received: by mail-ie0-f178.google.com with SMTP id rl12so4556301iec.23
        for <netdev@vger.kernel.org>; Sun, 08 Jun 2014 08:24:17 -0700 (PDT)
In-Reply-To: <539476D7.8020300@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/08/14 10:44, Roopa Prabhu wrote:

> sure, you seemed to be using my below patch in your examples for fdb
> filtering.
> so thought i should resubmit. I am now ok with either.

Yes, my patch is on top of your earlier (version 1) patch. I preferred
that version.

I looked at the code a little more after sending that email.
There is some value in displaying a bridge port's unicast addresses
and even setting them; but only in the case that the bridge port is
itself an owner of an fdb. As an example of such a case when you have
another bridge attached to a bridge as a port; or when you have
something like a vxlan as a bridge port etc.
However, current code does not discriminate. I cant make sense of
why this would be intentional but possibly i am missing some use cases.

cheers,
jamal
