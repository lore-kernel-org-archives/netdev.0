From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: on the wire behaviour of TSO on/off is supposed to be the same yes?
Date: Fri, 21 Jan 2005 13:58:53 -0600
Message-ID: <200501211358.53783.jdmason@us.ibm.com>
References: <41F1516D.5010101@hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <41F1516D.5010101@hp.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The benefit of TSO is not throughput, but CPU utilization.  Throughput 
increase is usually a side effect because of better PCI DMA behavior (eg. 
large PCI transfers are better).  Are you seeing a CPU utilization decrease?

On Friday 21 January 2005 01:01 pm, Rick Jones wrote:
> Is it indeed supposed to be the case that the on the wire behaviour of TCP with 
> TSO on/off is supposed to be the same?  I'm seeing some cases (netperf 
> TCP_STREAM 2.6.10 sending to HP-UX 11.23) where the throughput differences are 
>  >= 10 MB/s on an e1000 card (TSO being slower).  I've got lots of netperf and 
> tcpdump but thought I'd ask first before dumping it onto the list.  Actually, 
> i'll probably have to put it up on the net somewhere since it is O(200MB) in 
> total (although I have a smaller point example).
> 
> sincerely,
> 
> rick jones
> 
> 
> 

-- 
Jon Mason
jdmason@us.ibm.com
