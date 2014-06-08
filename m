From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH iproute2 v3] bridge: Add master device name to bridge
 fdb show
Date: Sun, 08 Jun 2014 15:25:54 -0700
Message-ID: <5394E2F2.70301@cumulusnetworks.com>
References: <1402205022-7083-1-git-send-email-roopa@cumulusnetworks.com> <539447F6.9040906@mojatatu.com> <539476D7.8020300@cumulusnetworks.com> <5394801D.6080704@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, stephen@networkplumber.org,
	netdev@vger.kernel.org, wkok@cumulusnetworks.com,
	sfeldma@cumulusnetworks.com, shm@cumulusnetworks.com,
	Vlad Yasevich <vyasevic@redhat.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:53426 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932276AbaFHW0A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Jun 2014 18:26:00 -0400
In-Reply-To: <5394801D.6080704@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/8/14, 8:24 AM, Jamal Hadi Salim wrote:
> On 06/08/14 10:44, Roopa Prabhu wrote:
>
>> sure, you seemed to be using my below patch in your examples for fdb
>> filtering.
>> so thought i should resubmit. I am now ok with either.
>
> Yes, my patch is on top of your earlier (version 1) patch. I preferred
> that version.

ok, yes, i thought so. And  this version (v3) is same as v1
>
> I looked at the code a little more after sending that email.
> There is some value in displaying a bridge port's unicast addresses
> and even setting them; but only in the case that the bridge port is
> itself an owner of an fdb. As an example of such a case when you have
> another bridge attached to a bridge as a port; or when you have
> something like a vxlan as a bridge port etc.
> However, current code does not discriminate. I cant make sense of
> why this would be intentional but possibly i am missing some use cases.
>
> cheers,
> jamal
>
