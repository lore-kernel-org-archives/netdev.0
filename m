From: jamal <hadi@cyberus.ca>
Subject: Re: some bug in iproute2
Date: Fri, 07 Aug 2009 10:28:05 -0400
Message-ID: <1249655285.7101.6.camel@dogo.mojatatu.com>
References: <20090807101250.GA14064@ff.dom.local>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Sergey Popov <popov_sergey@ukr.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f177.google.com ([209.85.211.177]:63239 "EHLO
	mail-yw0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932291AbZHGOaG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2009 10:30:06 -0400
Received: by ywh7 with SMTP id 7so2188694ywh.21
        for <netdev@vger.kernel.org>; Fri, 07 Aug 2009 07:30:06 -0700 (PDT)
In-Reply-To: <20090807101250.GA14064@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-08-07 at 10:12 +0000, Jarek Poplawski wrote:
> On 06-08-2009 10:50, Sergey Popov wrote:

> If you're using iptables > 1.4.2 then it's a known problem.
> You can read more in a netdev thread:
> Subject: iproute2 action/policer question
> starting date: Tue, 09 Jun 2009 22:10:46 +0200

I am giving up on fixing it for that release for general distros.
I will wait until iptables 1.4.4 becomes mainstream then i will make
another fix. It is very hard to keep up concurently with a) apis
changing randomly on the part of iptables b) distros picking random
versions of iptables and c) iproute2 being released in random
uncoordinated manner.
Maybe a solution that would work is to fork iproute2 or make ipt
part of iptables. In the meantime i can work with anyone who wants
to get it to work with fixed version of iproute2 + iptables. Sergey,
if this is of interest to you let me know.

cheers,
jamal

