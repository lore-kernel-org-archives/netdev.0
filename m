From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH]snmp6 64-bit counter support in proc.c
Date: Wed, 28 Jan 2004 11:33:36 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040128113336.7a6cb77d.davem@redhat.com>
References: <OFB07FA138.DADDB14B-ON88256E29.00692BAE@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, mashirle@us.ibm.com, netdev@oss.sgi.com,
        xma@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Krishna Kumar <kumarkr@us.ibm.com>
In-Reply-To: <OFB07FA138.DADDB14B-ON88256E29.00692BAE@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 28 Jan 2004 11:19:36 -0800
Krishna Kumar <kumarkr@us.ibm.com> wrote:

[ ... idea to use seq locks ]
> Does that sound better ?

Well, I thought the goal was to move the expensive part of doing
this out of the writers, which we assume will exceed readers.
Seq locks favor readers, and assume that the write is the less
common operation.

Putting seq locks around every stat counter bump is going to plump
up the code a lot.

Maybe your idea and original assumption are fine, in essence we live
with this now, don't we? :-)

Perhaps there are some better ideas?
