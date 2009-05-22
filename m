From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC 1/2] net: Introduce recvmmsg socket syscall
Date: Fri, 22 May 2009 16:06:11 -0400
Message-ID: <20090522200611.GB967@hmsreliant.think-freely.org>
References: <20090520230652.GB5956@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Chris Van Hoof <vanhoof@redhat.com>,
	Clark Williams <williams@redhat.com>
To: Arnaldo Carvalho de Melo <acme@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:58904 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756939AbZEVUG0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2009 16:06:26 -0400
Content-Disposition: inline
In-Reply-To: <20090520230652.GB5956@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 20, 2009 at 08:06:52PM -0300, Arnaldo Carvalho de Melo wrote:
> Meaning receive multiple messages, reducing the number of syscalls and
> net stack entry/exit operations.
> 
> Next patches will introduce mechanisms where protocols that want to
> optimize this operation will provide an unlocked_recvmsg operation.
> 


Not to throw more questions into the mix again, but didn't Ingo write a
batching syscall a while back, which let you issue several syscalls in one trap
to kernel space?  I understand that your approach has some efficiency gains over
that, but did that ever get accepted upstream?  Is the overlap there sufficient
to make this approach redundant?  Or are the gains in performance here
sufficient to warrant this new call?

Regards
Neil
