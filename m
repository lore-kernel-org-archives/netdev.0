From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [Bugme-new] [Bug 41152] New: kernel 3.0 and above fails to
 handle vlan id 0 (802.1p) packets properly without hardware acceleration
Date: Thu, 18 Aug 2011 18:37:03 +0200
Message-ID: <20110818163702.GA1911@minipsycho>
References: <bug-41152-10286@https.bugzilla.kernel.org/>
 <20110816150918.5b2d7067.akpm@linux-foundation.org>
 <20110817053737.GA1936@minipsycho>
 <4E4B615F.8060403@gmail.com>
 <20110817105950.GA4259@minipsycho.brq.redhat.com>
 <4E4C4549.6020802@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: Mike Auty <mike.auty@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23917 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755150Ab1HRQhK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Aug 2011 12:37:10 -0400
Content-Disposition: inline
In-Reply-To: <4E4C4549.6020802@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Aug 18, 2011 at 12:48:41AM CEST, mike.auty@gmail.com wrote:
>On 17/08/11 11:59, Jiri Pirko wrote:
>> 
>> I just obtained very similar card (8086:422b). Going to look at it right
>> away.
>> 
>> One more thing. What do you use to generate vlan0 tagged packets? I'm
>> using pktgen with "vlan_id 0". Would you please try that it behaves the
>> same for you?
>> 	
>
>Sorry, I haven't been using pktgen.  I've got an actual device (a
>Samsung android phone) which seems to tag all normal outbound packets
>with this type of vlan tag.  I only discovered a month ago that I needed
>the 8021q module to be able to talk to it, and then suddenly it stopped
>working once I moved to the 3.0 kernel.
>
>I might not have made it clear, but the packets are received (in so much
>as the packet is definitely sent, and it's seen by tools such as
>wireshark), but no reply is ever sent.  I've attached packet logs from
>the 3.0.1 kernel and the 2.6.39.3 kernel.  Oddly the tagging only seems
>to be used on the first SYN,ACK packet, but again I don't know enough
>about the pipeline or what the Samsung kernel's doing to cause that.
>
>I hope that's of some help?  I may be able to get systemtap support
>rolled into my kernel tomorrow at some point, but if not then it will
>have to wait until the weekend.  I don't know if that will provide
>useful information for debugging this, but I am happy to run whatever
>tests I can to figure this out...
>
>Mike  5:)

Patch posted:
http://patchwork.ozlabs.org/patch/110535/

sorry I forgot to cc you Mike. Thanks a lot for report!

Jirka


