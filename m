From: "David S. Miller" <davem@redhat.com>
Subject: Re: FW: [PATCH] - Incorrect cpumask definition in net/core/flow.c
Date: Fri, 7 Nov 2003 16:12:12 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031107161212.5521629b.davem@redhat.com>
References: <20031107223729.GA20687@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jack Steiner <steiner@sgi.com>
In-Reply-To: <20031107223729.GA20687@sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 7 Nov 2003 16:37:29 -0600
Jack Steiner <steiner@sgi.com> wrote:

> The field "cpumap" is defined as a "unsigned long". It 
> should be a "cpumask_t".

You can't just do this, that's more broken than the original
code.

You have to _ALSO_ change all of the accesses to these objects
to use the cpumask interfaces.
