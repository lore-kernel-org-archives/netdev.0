From: Eran Mann <emann@mrv.com>
Subject: Re: VLAN patches
Date: Mon, 07 Oct 2002 09:09:38 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DA13332.4080109@mrv.com>
References: <20021005.220549.15266753.davem@redhat.com>	<Pine.GSO.4.30.0210061839210.1861-100000@shell.cyberus.ca> <20021006.194654.35505461.davem@redhat.com> <3DA1010A.8020202@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, hadi@cyberus.ca,
   Bjorn.Andersson@ebc.ericsson.se, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

According to 802.1Q (which is BTW available freely from IEEE's site) 
0xFFF VID is "Reserved for implementation use. This VID value shall not 
be configured as a PVID, configured in any Filtering Database entry, 
used in any Management operation, or transmitted in a tag header.".

Regarding the 0 VID it is indeed used for priority-only frames. 
Shouldn't it be supported by alowing the user to configure a priority 
map for the ethernet device (rather than creating another user-visible 
device?

Ben Greear wrote:
> David S. Miller wrote:
>>    From: jamal 
>>       A packet with VLANid 0 and an 802.1p tag > 0 is legal. I
>>    think its known as a "priority tagged" packet (not 100% sure
>>    about the term). Therefore VLANid 0 MUST be accepted and ability to 
>>    send it should be there.
>>
>> Great, I stand corrected, please send me a patch which therefore
>> accepts VID 0 on create and destroy.
 >
> It already accepts on create, you just need to add the patch that
> was already sent to allow for delete.
> 
>>    BTW, what about VLANid 0xFFF?
> 
> I think it is reserved, but my spec is 3 years old, and I don't know
> where it is right now, so whatever it is now, let's not touch it :)

-- 
Eran Mann
Senior Software Engineer
MRV International
Tel: 972-4-9936297
Fax: 972-4-9890430
www.mrv.com
