From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6 MIB:ipv6RouterAdvert netlink notification
Date: Fri, 16 Jan 2004 12:08:35 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040116120835.7f32f5e5.davem@redhat.com>
References: <OF6E7E4DFA.6824D151-ON87256E1D.006A89B5@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, mashirle@us.ibm.com, kuznet@ms2.inr.ac.ru,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Shirley Ma <xma@us.ibm.com>
In-Reply-To: <OF6E7E4DFA.6824D151-ON87256E1D.006A89B5@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 16 Jan 2004 11:41:59 -0800
Shirley Ma <xma@us.ibm.com> wrote:

> Does netlink support user-user communication?

Yes, it does.

One thing I want people to keep in mind in these discussions, while I understand
the concerns being addressed and discussed, I think it would be somewhat rediculious
for one to be required to go to multiple places just to put a complete ipv6 mib together.

For example, a bunch of procfs files, some netlink stuff, and some status files emitted
by some userlevel daemon.  This is the situation I'd like to see avoided.

It looks like we can push all of this stuff over netlink, which would be ideal.
