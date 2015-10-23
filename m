From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [Xen-devel] [PATCH 0/2] limit xen vnic max queues number
 to online cpu number
Date: Fri, 23 Oct 2015 03:28:26 -0600
Message-ID: <562A19DA02000078000ADEE0@prv-mh.provo.novell.com>
References: <5629E796.5040203@oracle.com>
 <9AAE0902D5BC7E449B7C8E4E778ABCD02F6220AF@AMSPEX01CL01.citrite.net>
 <5629F851.6010309@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: "Ian Campbell" <Ian.Campbell@citrix.com>,
	"Paul Durrant" <Paul.Durrant@citrix.com>,
	"Wei Liu" <wei.liu2@citrix.com>,
	"David S. Miller" <davem@davemloft.net>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	"Boris Ostrovsky" <boris.ostrovsky@oracle.com>,
	"Konrad Rzeszutek Wilk" <konrad.wilk@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Joe Jin" <joe.jin@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prv-mh.provo.novell.com ([137.65.248.74]:41835 "EHLO
	prv-mh.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752133AbbJWJ22 convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:5:1>);
	Fri, 23 Oct 2015 05:28:28 -0400
In-Reply-To: <5629F851.6010309@oracle.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 23.10.15 at 11:05, <joe.jin@oracle.com> wrote:
> On 10/23/2015 04:47 PM, Paul Durrant wrote:
>>> -----Original Message-----
>>> From: netdev-owner@vger.kernel.org [mailto:netdev-
>>> owner@vger.kernel.org] On Behalf Of Joe Jin
>>> Sent: 23 October 2015 08:54
>>> To: Wei Liu; Ian Campbell; Boris Ostrovsky; Konrad Rzeszutek Wilk; David S.
>>> Miller
>>> Cc: netdev@vger.kernel.org; xen-devel@lists.xenproject.org 
>>> Subject: [PATCH 0/2] limit xen vnic max queues number to online cpu
>>> number
>>>
>>> Currently xen vnic allowed to create lots of queues by set module param
>>> max_queues(both netback and netfront), when queues number larger than
>>> cpu number, it does not help for performance but need more cpu time.
>>>
>> 
>> But it's an override, so why would you want to limit it? The parameter 
> should not be set in the common case.
> 
> Always we can not stop people use it because we provided it :)

Well, it's always a question of whether preventing the admin to
shoot himself in the foot makes sense: When it leads to an unusable
system, it probably does. When it leads to a sub-optimal working
system, perhaps we should allow them their freedom?

Jan
