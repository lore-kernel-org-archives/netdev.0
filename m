From: Chuck Lever <cel@citi.umich.edu>
Subject: Re: 2.6.11 oops in skb_drop_fraglist
Date: Mon, 21 Mar 2005 21:40:57 -0500
Message-ID: <423F85B9.3020406@citi.umich.edu>
References: <423097D5.30605@citi.umich.edu> <20050321162444.31c6c68d.akpm@osdl.org>
Reply-To: cel@citi.umich.edu
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090503080202090607040601"
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20050321162444.31c6c68d.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090503080202090607040601
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Andrew Morton wrote:
> Chuck Lever <cel@citi.umich.edu> wrote:
> 
>>testing NFS client workloads on a dual Pentium-III system running 2.6.11 
>>with some NFS patches.  i hit this oops while doing simple-minded ftps 
>>and tars.
>>
>>the system locks up once or twice a day under this workload.  this is 
>>the first time i had the console and captured the oops output.
>>
> 
> 
> Chuck, I didn't see any followup to this.  Is it still happening in current
> kernels?

i have not been able to reproduce it with the aforementioned NFS patches 
removed.  i'm now convinced it was a bug in one of the NFS patches i had 
applied, even though none of them come near the fraglist stuff, but i 
haven't had a chance to nail it down.

i had implemented a patch to cause the RPC client to reuse the port 
number when reconnecting to the server after the server drops the 
connection... this is a standard practice for other RPC implementations. 
  i suspect it was that patch that was causing the trouble.

thanks for the follow-up!

--------------090503080202090607040601
Content-Type: text/x-vcard; charset=utf-8;
 name="cel.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="cel.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Charles
org:Network Appliance, Incorporated;Linux NFS Client Development
adr:535 West William Street, Suite 3100;;Center for Information Technology Integration;Ann Arbor;MI;48103-4943;USA
email;internet:cel@citi.umich.edu
title:Member of Technical Staff
tel;work:+1 734 763-4415
tel;fax:+1 734 763 4434
tel;home:+1 734 668-1089
x-mozilla-html:FALSE
url:http://www.monkey.org/~cel/
version:2.1
end:vcard


--------------090503080202090607040601--
