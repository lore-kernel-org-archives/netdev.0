From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [iproute2] tc: Show classes more hierarchically]
Date: Thu, 18 Dec 2014 14:47:38 +0100
Message-ID: <5492DAFA.5070001@redhat.com>
References: <20141215224851.GB6734@angus-think.lan> <54907619.5080508@gmail.com> <20141217115535.3f5198d2@urahara> <20141217235627.GA2149@angus-think.lan> <54923434.3030209@gmail.com> <20141218031257.GA19527@angus-think.lan> <5492C7FD.8060603@gmail.com> <20141218122329.GA31878@angus-think.lan> <5492CC8E.6050108@gmail.com> <20141218131653.GA5980@angus-think.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, jhs@mojatatu.com
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34267 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751916AbaLRNrt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Dec 2014 08:47:49 -0500
In-Reply-To: <20141218131653.GA5980@angus-think.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/18/2014 02:16 PM, Vadim Kochan wrote:
...
> The problem that this is huge now but looks better visually, I am
> thinking also about to possibiliy to show only some part of tree by specified parent id ...

I definitely like this work!

Just thinking out loud, what about an output option for tc which is plain
DOT [1], thus it can be handed over for rendering in tools like graphviz?

It won't require any dependencies either as it's just plaintext.

   [1] https://en.wikipedia.org/wiki/DOT_%28graph_description_language%29
