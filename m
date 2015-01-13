From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net] gso: do GSO for local skb with size bigger than MTU
Date: Tue, 13 Jan 2015 16:58:24 +0000
Message-ID: <20150113165824.GA14940@casper.infradead.org>
References: <54AA2912.6090903@gmail.com>
 <CAEP_g=-R1FrcA0sTJJjQhypRtVCwoRZ+LieKaSJxqA-HACZqEw@mail.gmail.com>
 <54ABAC13.9070402@gmail.com>
 <CAEP_g=8bCR=PeSoi09jLWLtNUrxhzx45h1Wm=9D=R57AqUac2w@mail.gmail.com>
 <54ACCAFD.4070203@gmail.com>
 <CAEP_g=8EBeQUFkRRsG3sznYryd+LE9qJKWQXfS==HG2HDO=UKA@mail.gmail.com>
 <54AE506A.5020207@gmail.com>
 <CAEP_g=9hh+MG7AWEnct7CwRqp=ZghpbkDeQ5BhGQktDgMST1jA@mail.gmail.com>
 <54AF6B9F.6080104@gmail.com>
 <CAEP_g=_+sPkuib6CNsSEHB0txW+rEVzOVRXKfkYO=FLqR=8uFQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Fan Du <fengyuleidian0615@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	"Du, Fan" <fan.du@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Jason Wang <jasowang@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"fw@strlen.de" <fw@strlen.de>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	"pshelar@nicira.com" <pshelar@nicira.com>, fuscof@gmail.com
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:53326 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752413AbbAMQ62 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 11:58:28 -0500
Content-Disposition: inline
In-Reply-To: <CAEP_g=_+sPkuib6CNsSEHB0txW+rEVzOVRXKfkYO=FLqR=8uFQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/12/15 at 10:55am, Jesse Gross wrote:
> There are at least two parts to this:
>  * Calculating the right MTU for the guest device.
>  * Transferring the MTU from the host to the guest.
> 
> The first would presumably involve exposing some kind of API that the
> component that does know the right value could program. In this case,
> that component could be OVS using the same type of information that
> you just described in the earlier post about L3. The API could simply
> to just set the MTU of the device in the host and this gets mirrored
> to the guest.
> 
> The second part I guess is probably a fairly straightforward extension
> to virtio but I don't know the details.

Francesco Fusco wrote code to do exactly this. Maybe he still has
it somewhere.
