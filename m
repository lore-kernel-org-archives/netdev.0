From: Dave Hansen <haveblue@us.ibm.com>
Subject: Re: Early SPECWeb99 results on 2.5.33 with TSO on e1000
Date: Thu, 05 Sep 2002 16:01:32 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D77E24C.8020808@us.ibm.com>
References: <200209052211.g85MBFdm099387@tempest.prismnet.com> <1031265571.3d77dd23caec4@imap.linux.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Troy Wilson <tcw@tempest.prismnet.com>, jamal <hadi@cyberus.ca>,
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Nivedita Singhvi <niv@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Nivedita Singhvi wrote:
> SpecWeb99 doesnt execute the path that might benefit the 
> most from this patch - sendmsg() of large files - large writes
> going down..

For those of you who don't know Specweb well, the average size of a request 
is about 14.5 kB.  The largest files are ~5mb, but the largest top out at 
just under a meg.

-- 
Dave Hansen
haveblue@us.ibm.com
