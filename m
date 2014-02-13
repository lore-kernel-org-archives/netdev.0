From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: RFC: bridge get fdb by bridge device
Date: Thu, 13 Feb 2014 08:03:03 -0800
Message-ID: <52FCECB7.8080105@intel.com>
References: <52F21F72.2090405@mojatatu.com> <52F29747.7040008@redhat.com> <52F3CF76.9090404@mojatatu.com> <52F3E357.4040006@redhat.com> <52F79990.3000400@mojatatu.com> <52F8FEF1.60407@redhat.com> <52FA58E9.906@mojatatu.com> <52FA6A24.3030402@redhat.com> <52FA84FA.2030608@mojatatu.com> <52FA8865.1070302@intel.com> <52FA9074.2060900@mojatatu.com> <52FBC282.6020301@intel.com> <52FCE69F.5080602@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Scott Feldman <sfeldma@cumulusnetworks.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:45553 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751252AbaBMQGh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Feb 2014 11:06:37 -0500
In-Reply-To: <52FCE69F.5080602@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/13/2014 7:37 AM, Jamal Hadi Salim wrote:
> On 02/12/14 13:50, John Fastabend wrote:
>> On 2/11/2014 1:04 PM, Jamal Hadi Salim wrote:
>>
>> Because it is not the same type of object as the software bridge.
>> Most notably it doesn't do learning.
>
> This kept nagging at me.
> Learning is optional for a bridge. So is flooding.
> I think we got this right in recent kernels.
>
> cheers,
> jamal

Yeah I remember now Vlad added them. The real distinction
is macvlan devices only have _one_ uplink port and support
other forwarding modes, VEPA, etc.
