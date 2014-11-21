From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCHv10 ovs 03/15] datapath: Add 'is_mask' to ovs_nla_put_flow().
Date: Fri, 21 Nov 2014 10:17:19 -0800
Message-ID: <CALnjE+rg_UYkLjocyhm-sW1hRbNrOza=uYR9NqXOHZ85wnRr+w@mail.gmail.com>
References: <1415906275-3172-1-git-send-email-joestringer@nicira.com>
	<1415906275-3172-4-git-send-email-joestringer@nicira.com>
	<CANr6G5x4ObV4r3G1wLd+51nr=oYtwt=ConknjO29VkNT-vvrmA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog113.obsmtp.com ([74.125.149.209]:54341 "HELO
	na3sys009aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751514AbaKUSRT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 13:17:19 -0500
Received: by mail-ie0-f174.google.com with SMTP id rl12so5436804iec.33
        for <netdev@vger.kernel.org>; Fri, 21 Nov 2014 10:17:19 -0800 (PST)
In-Reply-To: <CANr6G5x4ObV4r3G1wLd+51nr=oYtwt=ConknjO29VkNT-vvrmA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 20, 2014 at 4:15 PM, Joe Stringer <joestringer@nicira.com> wrote:
> On 13 November 2014 11:17, Joe Stringer <joestringer@nicira.com> wrote:
>> This function previously hid the 'is_mask' parameter from the callers,
>> which actually have better knowledge about whether it is serializing a
>> mask or not. Expose this parameter to the callers. This allows the same
>> function to be called to serialize masked keys as well as masked keys.
>>
>> To serialize an unmasked key:
>> ovs_nla_put_flow(key, key, skb, false);
>>
>> To serialize a masked key:
>> ovs_nla_put_flow(mask, key, skb, false);
>>
>> To serialize a mask:
>> ovs_nla_put_flow(key, mask, skb, true);
>
> I'll add helpers for each of these functions:
> ovs_nla_put_{un,}masked_key(), ovs_nla_put_mask() in the next version.

sounds good to me.
