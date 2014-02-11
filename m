From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: RFC: bridge get fdb by bridge device
Date: Tue, 11 Feb 2014 16:08:55 -0500
Message-ID: <52FA9167.2040305@mojatatu.com>
References: <52F21F72.2090405@mojatatu.com> <52F29747.7040008@redhat.com> <52F3CF76.9090404@mojatatu.com> <52F3E357.4040006@redhat.com> <52F79990.3000400@mojatatu.com> <52F8FEF1.60407@redhat.com> <52FA58E9.906@mojatatu.com> <52FA6A24.3030402@redhat.com> <52FA84FA.2030608@mojatatu.com> <52FA8F8B.3080500@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: vyasevic@redhat.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:36388 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753296AbaBKVI5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 16:08:57 -0500
Received: by mail-ig0-f179.google.com with SMTP id c10so9714607igq.0
        for <netdev@vger.kernel.org>; Tue, 11 Feb 2014 13:08:57 -0800 (PST)
In-Reply-To: <52FA8F8B.3080500@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/11/14 16:00, Vlad Yasevich wrote:
> On 02/11/2014 03:15 PM, Jamal Hadi Salim wrote:

>
> Because it just a multi-function nic that isn't tagged with any
> kine of bridge flag.  As John said, this might be useful, but not
> done yet.
>

Ok, fair enough. Someone should send a patch - John perhaps.

>
> Not directly.  However, if you put a layered software device in between
> (vlan, bond, macvlan), then you can add that device to another bridge.
> In fact, people do that to get GVRP working with VMs.
>

Do you recall the reasoning behind it?


>> It certainly has some equivalent semantics (looks at dst MAC then
>> picks the port). Possible to add Vlans as well?
>
> I suppose.   You can do things like:
> # ip link add link eth0 dev vlan100 protocol 8021Q id 100
> # ip link add link vlan0 dev mac100 type macvlan
>
> Now, you have a macvlan (mac100) that will only receive vlan100 traffic.
> Expressing this in terms of fdb would be a bit difficult since each
> interface is separate and eth0 doesn't really know about the stack.
> It would require quite a lot of code.
>

nice.

>> Why dont we tag such a thing as a bridge then?
>>
>
> Because they are not always a bridge.  It could be just a nic capable of
> mac filtering.
>

I think in one of the modes it is merely a filter.
But you turn on this other feature it is a bridge.

>
> Didn't realize it has different connotation for vxlan.  The you probably
> don't want to include and support in the bridge fdb show command.

Thats what i thought you said earlier ;->

cheers,
jamal
