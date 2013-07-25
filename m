From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next] tuntap: hardware vlan tx support
Date: Thu, 25 Jul 2013 11:31:55 +0800
Message-ID: <51F09C2B.2080802@redhat.com>
References: <1374563748-38821-1-git-send-email-jasowang@redhat.com> <20130723085310.4a036a47@nehalam.linuxnetplumber.net> <51EF6C42.1070304@redhat.com> <20130724081139.28ba3429@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Basil Gor <basil.gor@gmail.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130724081139.28ba3429@nehalam.linuxnetplumber.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/24/2013 11:11 PM, Stephen Hemminger wrote:
> On Wed, 24 Jul 2013 13:55:14 +0800
> Jason Wang <jasowang@redhat.com> wrote:
>
>> On 07/23/2013 11:53 PM, Stephen Hemminger wrote:
>>> On Tue, 23 Jul 2013 15:15:48 +0800
>>> Jason Wang <jasowang@redhat.com> wrote:
>>>
>>>> +		struct {
>>>> +			__be16 h_vlan_proto;
>>>> +			__be16 h_vlan_TCI;
>>>> +		} veth;
>>> Don't you want to use struct vlan_hdr here? 
>> There's no need to care encapsulated proto here. In fact, we just
>> emulate the hardware inserting of 802.1Q header. So only skb->vlan_tci
>> and skb->vlan_proto needs to be cared.
>>> Your definition puts the two fields out of order?
>> It's order is same as struct vlan_ethhdr. Did you see any issue?
> I was looking at if_vlan.h struct vlan_hdr. The veth structure
> is a slice between ether and vlan header.

Right, so no functional issue.
