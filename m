From: Pranith Kumar <bobby.prani@gmail.com>
Subject: Re: [PATCH 16/16] rxrpc: Replace smp_read_barrier_depends() with
 lockless_dereference()
Date: Thu, 13 Nov 2014 16:55:11 -0500
Message-ID: <546528BF.5040902@gmail.com>
References: <1415906662-4576-17-git-send-email-bobby.prani@gmail.com> <1415906662-4576-1-git-send-email-bobby.prani@gmail.com> <24601.1415911646@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	"open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>,
	open list <linux-kernel@vger.kernel.org>,
	paulmck@linux.vnet.ibm.com
To: David Howells <dhowells@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <24601.1415911646@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/13/2014 03:47 PM, David Howells wrote:
> Pranith Kumar <bobby.prani@gmail.com> wrote:
> 
>> Recently lockless_dereference() was added which can be used in place of
>> hard-coding smp_read_barrier_depends(). The following PATCH makes the change.
> 
> Actually, the use of smp_read_barrier_depends() is wrong in circular
> buffering.  See Documentation/circular-buffers.txt
> 

OK. Should I send in a patch removing these barriers then?

--
Pranith
