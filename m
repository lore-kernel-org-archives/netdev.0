From: Bernhard Held <bheld@mgpi.de>
Subject: Re: KVM induced panic on 2.6.38[2367] & 2.6.39
Date: Fri, 03 Jun 2011 17:50:40 +0200
Message-ID: <isavsg$3or$1@dough.gmane.org>
References: <20110601011527.GN19505@random.random> <alpine.LSU.2.00.1105312120530.22808@sister.anvils> <4DE5DCA8.7070704@fnarfbargle.com> <4DE5E29E.7080009@redhat.com> <4DE60669.9050606@fnarfbargle.com> <4DE60918.3010008@redhat.com> <4DE60940.1070107@redhat.com> <4DE61A2B.7000008@fnarfbargle.com> <20110601111841.GB3956@zip.com.au> <4DE62801.9080804@fnarfbargle.com> <20110601230342.GC3956@zip.com.au> <4DE8E3ED.7080004@fnarfbargle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: kvm@vger.kernel.org
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4DE8E3ED.7080004@fnarfbargle.com>
Cc: linux-mm@kvack.org, kvm@vger.kernel.org, netdev@vger.kernel.org
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 03.06.2011 15:38, schrieb Brad Campbell:
> On 02/06/11 07:03, CaT wrote:
>> On Wed, Jun 01, 2011 at 07:52:33PM +0800, Brad Campbell wrote:
>>> Unfortunately the only interface that is mentioned by name anywhere
>>> in my firewall is $DMZ (which is ppp0 and not part of any bridge).
>>>
>>> All of the nat/dnat and other horrible hacks are based on IP addresses.
>>
>> Damn. Not referencing the bridge interfaces at all stopped our host from
>> going down in flames when we passed it a few packets. These are two
>> of the oopses we got from it. Whilst the kernel here is .35 we got the
>> same issue from a range of kernels. Seems related.
>
> Well, I tried sending an explanatory message to netdev, netfilter & cc'd to kvm,
> but it appears not to have made it to kvm or netfilter, and the cc to netdev has
> not elicited a response. My resend to netfilter seems to have dropped into the
> bit bucket also.
Just another reference 3.5 months ago:
http://www.spinics.net/lists/netfilter-devel/msg17239.html

Bernhard

