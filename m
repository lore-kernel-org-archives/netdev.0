From: "David S. Miller" <davem@redhat.com>
Subject: Re: Useless networking code in 2.4.x ?
Date: Thu, 23 Oct 2003 03:31:00 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031023033100.1bc47d31.davem@redhat.com>
References: <20031023085801.40580.qmail@web11105.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: an7 <an3h0ny@yahoo.fr>
In-Reply-To: <20031023085801.40580.qmail@web11105.mail.yahoo.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 23 Oct 2003 10:58:01 +0200 (CEST)
an7 <an3h0ny@yahoo.fr> wrote:

> If we have a look at tcp_recv_skb, and
> tcp_read_sock(),
>
> we notice that there is a SYN check, and if the flag
> is on, we do offset-- (sequence number not
> corresponding to real data byte). 
>
> This Syn check is useless, as the function cannot be
> called at the beginning of a connection (since we have
> not copied_seq filled with the last sequence number of
> the last packet passed to the upper layer)
> 
> What do you think of that ?

Please next time, take this kind of question to netdev@oss.sgi.com
where the networking developers are, most of them are not subscribed
to linux-kernel.

As to your question, if we ever support accepting data in the
initial final SYN-ACK packet, this code would be needed, so it's
better to keep this code around.
