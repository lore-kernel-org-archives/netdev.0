From: Venkat Yekkirala <vyekkirala@trustedcs.com>
Subject: Re: Labeled Networking Requirements and Design (formerly RE: [PATCH
 01/06] MLSXFRM: Granular IPSec associations for use in  MLS environments)
Date: Tue, 27 Jun 2006 10:47:27 -0500
Message-ID: <44A1530F.1020400@trustedcs.com>
References: <44A0684D.9080904@trustedcs.com> <44A152A6.3060809@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, netdev@vger.kernel.org, selinux@tycho.nsa.gov,
	davem@davemloft.net, sds@tycho.nsa.gov, eparis@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:45380 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S1161118AbWF0Prq
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 11:47:46 -0400
To: paul.moore@hp.com
In-Reply-To: <44A152A6.3060809@trustedcs.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Venkat Yekkirala wrote:
>> Keeping in mind (R1a), I wonder if it makes more sense for (OTBND1a) 
>> to take the label of the process/domain which sends the data to the 
>> socket? After all, the process/domain is the "origin" of the data.
> 
> Right. This is what "ends up" happening in the non-privileged case. In the
> privileged multi-level process case, the label of the data has in fact been
> established at the socket creation time itself, and here we are trusting 
> the
> privileged multi-level process with sending data out on the right socket 
> with
> the knowledge that the data would be labeled with the label of the socket.
> 
>>  This seems to be particularly important in the case of 
>> fork()-then-exec() where you could have a socket created at a 
>> different context from the domain currently writing to it.
> 
> It would also help to remember that there are additional process-to-socket
> controls (sendmsg, recvmsg) already in place in SELinux.
> 
In summary it's a matter of architecture.
