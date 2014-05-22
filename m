From: Bart De Schuymer <bdschuym@pandora.be>
Subject: Re: Revert 462fb2af9788a82a534f8184abfde31574e1cfa0 (bridge : Sanitize
 skb before it enters the IP stack)
Date: Thu, 22 May 2014 20:57:08 +0200
Message-ID: <537E4884.7060205@pandora.be>
References: <537621AC.1060409@davidnewall.com> <5379FFFD.1050705@davidnewall.com> <20140519140119.GA24523@breakpoint.cc> <537A12EA.4060604@davidnewall.com> <20140519170915.GB24523@breakpoint.cc> <537A6E5C.6090602@pandora.be> <537C5A6C.3030809@davidnewall.com> <537CF5A2.3080401@pandora.be> <537D73ED.4010400@davidnewall.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: David Newall <davidn@davidnewall.com>,
	Florian Westphal <fw@strlen.de>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from andre.telenet-ops.be ([195.130.132.53]:39642 "EHLO
	andre.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750890AbaEVS5M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 14:57:12 -0400
In-Reply-To: <537D73ED.4010400@davidnewall.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Newall schreef op 22/05/2014 5:50:
> On 22/05/14 04:21, Bart De Schuymer wrote:
>> As for your other remark: as I've said before, if you don't like
>> bridge-netfilter then don't compile it into your kernel.
>
> That's not very helpful.  I could say, with just as much merit, that it
> should be marked deprecated (so that it's not compiled into distribution
> kernels) and you can compile it into yours.
>
> What I dislike is that bridge-netfilter is faulty.

I can see this may be frustrating to many. Now and then I actually got 
some positive feedback :-) Anyway, since I didn't have much sleep last 
night I'll be brief.
I'm fine with deprecating ebtables/bridge-nf. The code is over a decade 
old and development hasn't really picked up speed after I diverted my 
spare time to other things.
 From now on I'm no longer wasting my spare time on involvement in 
bridge-nf/ebtables. Anyone that wants to step up to take over the git 
repository (also contains arptables userspace app) can please contact me 
by private mail.

Best regards,
Bart
