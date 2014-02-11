From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: RFC: bridge get fdb by bridge device
Date: Tue, 11 Feb 2014 12:21:45 -0800
Message-ID: <52FA8659.9010001@intel.com>
References: <52F21F72.2090405@mojatatu.com> <52F29747.7040008@redhat.com> <52F3CF76.9090404@mojatatu.com> <52F3E357.4040006@redhat.com> <52F79990.3000400@mojatatu.com> <52F8FEF1.60407@redhat.com> <52FA58E9.906@mojatatu.com> <52FA6A24.3030402@redhat.com> <52FA84FA.2030608@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Scott Feldman <sfeldma@cumulusnetworks.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:37759 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753822AbaBKUVr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Feb 2014 15:21:47 -0500
In-Reply-To: <52FA84FA.2030608@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/11/2014 12:15 PM, Jamal Hadi Salim wrote:
>
>>
>> Yes, macvlan can forward data to other macvlans, but that's
>> not the interesting thing.
>
> Sample config?

ip link add link ethx name mv1 type macvlan mode bridge
ip link add link ethx name mv2 type macvlan mode bridge

Now you have a macvlan on ethx that will forward data between
mv1 and mv2.
