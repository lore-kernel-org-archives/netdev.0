From: "David S. Miller" <davem@redhat.com>
Subject: Re: tcp socket missing from /proc/net/tcp
Date: Sat, 23 Aug 2003 17:27:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030823172710.478f30f9.davem@redhat.com>
References: <m3lltk17er.fsf@lugabout.jhcloos.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "James H. Cloos Jr." <cloos@jhcloos.com>
In-Reply-To: <m3lltk17er.fsf@lugabout.jhcloos.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 23 Aug 2003 15:49:16 -0400
"James H. Cloos Jr." <cloos@jhcloos.com> wrote:

> I've currently got an open ssh session to a remote box that does not
> show up in /proc/net/tcp (I also checked /proc/net/tcp6 even though
> the remote box doesn't do v6; it is not there either).

Not surprising, nothing seems to be initializing
net/ipv6/tcp_ipv6.c:tcp6_seq_fops

I'd welcome patches to fix this.
