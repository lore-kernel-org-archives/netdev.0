From: Hisham Kotry <etsh_cucu@yahoo.com>
Subject: Re: netlink tester program
Date: Tue, 3 Jun 2003 00:57:42 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030603075742.34434.qmail@web14305.mail.yahoo.com>
References: <20030602.203834.115933659.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rddunlap@osdl.org, linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: david-b@pacbell.net
In-Reply-To: <20030602.203834.115933659.davem@redhat.com>
List-Id: netdev.vger.kernel.org


--- "David S. Miller" <davem@redhat.com> wrote:
> There is even an official IETF RFC written by Jamal,
> Alexey, and
> others documenting netlink btw :-))))))))))))
> 
> Did anybody notice this?

It was defenitly a nice read, but the netlink2 draft
is somewhat inconsistent, it mentions reducing the
32-bit length field to 16-bits and equally
distributing the remaining 16-bits between the new
version and extended flags fields, but the draft makes
no further refrence to the version field. Infact the
netlink2 message header diagram on page 16, as well as
the pseudo message on page 28, show a 16-bits extended
flags field with no version field in the header. So
this is probably one of those cases in wich specs
aren't clear enough and code usually has the final
word in such situations.

I mailed Jamal about this a while ago but never got a
reply back.

BTW, is netlink2 support planned for linux in the near
future?

David, sorry for the private mail, but it was
unintentional as I (by mistake) pressed reply instead
of reply all.

Chaow,
kotry


__________________________________
Do you Yahoo!?
Yahoo! Calendar - Free online calendar with sync to Outlook(TM).
http://calendar.yahoo.com
