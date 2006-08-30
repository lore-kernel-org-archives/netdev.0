From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 0/3] secid reconciliation-v01: Repost patchset with up
 dates
Date: Wed, 30 Aug 2006 16:21:46 -0400
Message-ID: <44F5F35A.7000904@hp.com>
References: <36282A1733C57546BE392885C0618592014C066C@chaos.tcs.tcs-sec.com> <Pine.LNX.4.64.0608251025120.23473@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: James Morris <jmorris@namei.org>, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov, Stephen Smalley <sds@tycho.nsa.gov>,
	Chad Hanson <chanson@TrustedCS.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:17325 "EHLO atlrel7.hp.com")
	by vger.kernel.org with ESMTP id S1751489AbWH3UVu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2006 16:21:50 -0400
To: Venkat Yekkirala <vyekkirala@TrustedCS.com>
In-Reply-To: <Pine.LNX.4.64.0608251025120.23473@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Morris wrote:
> On Fri, 25 Aug 2006, Venkat Yekkirala wrote:
>>>I like these changes, but wondering why you haven't supplied 
>>>code for the 
>>>outbound case ?
>>
>>The code for the outbound is still in the works. I hope to have it
>>out in a week or so.
> 
> Ok, I guess we should wait until then before incorporating the patches 
> (also, for Paul Moore to return and comment re. CIPSO).

My main concern with these patches is that moving the NetLabel check out
of selinux_socket_sock_rcv_skb() and into selinux_skb_policy_check() (as
it is currently written) would force us to compare a packet's NetLabel
with either the IPsec label or the secmark label and not the socket's
label.  The ability to make access decisions based on the process
consuming the data and the data itself it one of the nicer qualities of
NetLabel in my opinion.

Like James, I'd also like to see the outbound side too.

-- 
paul moore
linux security @ hp
