From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] NETFILTER module xt_hmark new target for HASH MARK
Date: Fri, 04 Feb 2011 14:20:05 +0100
Message-ID: <4D4BFD05.6030003@trash.net>
References: <1296740050-6311-1-git-send-email-hans.schillstrom@ericsson.com>	 <1296740050-6311-2-git-send-email-hans.schillstrom@ericsson.com>	 <4D4AB2D6.7070302@netfilter.org> <1296742995.6662.57.camel@seasc0214> <4D4ACCCB.8030902@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>,
	"jengelh@medozas.de" <jengelh@medozas.de>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hans@schillstrom.com" <hans@schillstrom.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4D4ACCCB.8030902@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03.02.2011 16:42, Pablo Neira Ayuso wrote:
> On 03/02/11 15:23, Hans Schillstrom wrote:
>>> If this is accepted, I think this has to be merge with the (already
>>> overloaded) MARK target.
>>
>> I have no opinion about that, others might have.
> 
> Better put it in the MARK target with a new revision. I think that
> Patrick is going to ask you this.
> 
> I don't know why I had the impression that MARK is overload, it's
> actually fine at a first glance to the code.

I don't think we should merge this with the MARK target, I don't
want to bloat the simple mark structure with all the parameters
needed for this module.
