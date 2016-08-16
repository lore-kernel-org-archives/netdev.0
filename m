From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: kernel panic in qdisc_match_from_root starting openvswitch
Date: Tue, 16 Aug 2016 14:06:57 -0600
Message-ID: <0655f5cc-d24b-6fe3-aaac-a71898dacda5@cumulusnetworks.com>
References: <bfb76544-6d3a-dcd4-9338-72ecfda9f691@cumulusnetworks.com>
 <alpine.LNX.2.00.1608162115510.22028@cbobk.fhfr.pm>
 <alpine.LNX.2.00.1608162150110.22028@cbobk.fhfr.pm>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Simon Horman <simon.horman@netronome.com>
To: Jiri Kosina <jikos@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:36479 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753736AbcHPUG7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2016 16:06:59 -0400
Received: by mail-pf0-f169.google.com with SMTP id h186so30591389pfg.3
        for <netdev@vger.kernel.org>; Tue, 16 Aug 2016 13:06:59 -0700 (PDT)
In-Reply-To: <alpine.LNX.2.00.1608162150110.22028@cbobk.fhfr.pm>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/16/16 1:51 PM, Jiri Kosina wrote:
> On Tue, 16 Aug 2016, Jiri Kosina wrote:
> 
>>> I am hitting a kernel panic with '/etc/init.d/openvswitch-switch 
>>> restart' Stack trace below. Reverting 59cc1f61f09c ("net: sched: convert 
>>> qdisc linked list to hashtable") clears the problem.
>>
>> Thanks a lot for the report. Could you please test either with the 
>> attached two patches applied on top of net-next, or alternatively with 
>> 'might-rebase/net-sched-qdiscs' branch of
>>
>> 	git://git.kernel.org/pub/scm/linux/kernel/git/jikos/jikos.git
>>
>> (HEAD of that branch is 60b3487ad7f) and report back to me whether it 
>> fixes any issues you are seeing? Applying the attached patches on top of 
>> net-next or testing with the git branch above should be equivalent test 
>> wrt. qdiscs.
> 
> And this time hopefully with the actual patches ... 
> 

Applied both and no longer see the panic starting openvswitch.
